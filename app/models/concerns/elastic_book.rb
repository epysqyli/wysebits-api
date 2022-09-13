# elasticsearch concern for Book model
module ElasticBook
  extend ActiveSupport::Concern

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

    def as_indexed_json
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

    def self.bulk_index(books)
      __elasticsearch__.client.bulk({
                                      index: __elasticsearch__.index_name,
                                      type: '_doc',
                                      body: map_for_import(books)
                                    })
    end

    def self.import
      includes(:category, :authors, book_tiles: :tile_entries).find_in_batches do |books|
        bulk_index(books)
      end
    end

    def elastic_tile_entries
      all_tile_entries.select(:id, :content, :upvotes, :downvotes, :net_votes, :created_at, :updated_at)
    end

    def self.search(elastic_query_instance, from = 0)
      __elasticsearch__.search(
        {
          query: elastic_query_instance.query,
          size: 20,
          from: from,
          highlight: {
            pre_tags: ['<b>'],
            post_tags: ['</b>'],
            fields: { title: {} }
          }
        }
      )
    end
  end
end
