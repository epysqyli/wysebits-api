# elasticsearch concern for Book model
module ElasticBook
  extend ActiveSupport::Concern

  ELASTIC_CONFIG_FILE = 'config/elastic.yaml'.freeze

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    after_commit on: %i[create update] do
      __elasticsearch__.index_document
    end

    after_commit on: :destroy do
      __elasticsearch__.delete_document
    end

    settings index: { number_of_shards: 2 } do
      mapping dynamic: false do
        indexes :title, type: :text, analyzer: :english
        indexes :tiles_count, type: :long
        indexes :category, type: :object do
          indexes :id, type: :long
          indexes :slug, type: :keyword
        end
        indexes :authors, type: :object do
          indexes :id, type: :long
          indexes :full_name, type: :text
        end
      end
    end

    def self.current_index_name
      es_config_yaml = YAML.load_file ELASTIC_CONFIG_FILE
      es_config_yaml['current_index_name']['books']
    end

    def as_indexed_json(_options = {})
      as_json(
        only: %i[id title ol_key cover_url tiles_count],
        include: [
          { category: { only: %i[id slug] } },
          { authors: { only: %i[id full_name key] } }
        ],
        methods: :elastic_tile_entries
      )
    end

    def self.map_for_import(books)
      Parallel.map(books, in_threads: 2) { |book| { index: { _id: book.id, data: book.as_indexed_json } } }
    end

    def self.bulk_index(books, index_name)
      __elasticsearch__.client.bulk({
                                      index: index_name || __elasticsearch__.index_name,
                                      type: '_doc',
                                      body: map_for_import(books)
                                    })
    end

    def self.import(options = {})
      index_name = options[:index_name]
      includes(:category, :authors, book_tiles: :tile_entries).find_in_batches do |books|
        bulk_index(books, index_name)
      end
    end

    def elastic_tile_entries
      all_tile_entries.select(:id, :content, :upvotes, :downvotes, :net_votes, :created_at, :updated_at)
    end

    def self.search(elastic_request_instance, from = 1)
      resp = __elasticsearch__.search(
        {
          query: elastic_request_instance.query,
          sort: elastic_request_instance.sort,
          size: ElasticRequest::SIZE,
          from: ((from.to_i * ElasticRequest::SIZE) - ElasticRequest::SIZE),
          highlight: {
            pre_tags: ['<b>'],
            post_tags: ['</b>'],
            fields: { title: {} }
          }
        },
        index: current_index_name
      )

      { total: resp.results.total, per_page: ElasticRequest::SIZE, results: resp.results }
    end
  end
end
