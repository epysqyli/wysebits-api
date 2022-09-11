# elasticsearch concern for Book model
module ElasticBook
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    def elastic_tile_entries
      all_tile_entries.select(:id, :content, :upvotes, :downvotes, :net_votes, :created_at, :updated_at)
    end

    def as_indexed_json(_options = {})
      as_json(
        only: %i[title ol_key cover_url tiles_count],
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
      where.not(category_id: 25).includes(:category, :authors).find_in_batches do |books|
        bulk_index(books)
      end
    end

    after_commit on: %i[create update] do
      __elasticsearch__.index_document
    end

    after_commit on: :destroy do
      __elasticsearch__.delete_document
    end

    mapping dynamic: false do
      indexes :title, type: :text, analyzer: :english
      indexes :category, type: :object do
        indexes :id, type: :long
        indexes :name, type: :keyword
      end
    end

    # generalize interface towards elastic to allow for more flexible queries
    def self.search(value, from = 0)
      __elasticsearch__.search(
        {
          query: {
            match:
            {
              title: {
                query: value,
                fuzziness: 'AUTO'
              }
            }
          },
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
