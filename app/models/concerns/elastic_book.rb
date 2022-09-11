# elasticsearch concern for Book model
module ElasticBook
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

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
      books.map { |book| { index: { _id: book.id, data: book.as_indexed_json } } }
    end

    def self.bulk_index(books)
      __elasticsearch__.client.bulk({
                                      index: __elasticsearch__.index_name,
                                      type: '_doc',
                                      body: map_for_import(books)
                                    })
    end

    def self.import
      where(category_id: 9).includes(:category, :authors).find_in_batches do |books|
        bulk_index(books)
      end
    end

    # callbacks to keep in sync with postgres
    after_commit on: %i[create update] do
      __elasticsearch__.index_document
    end

    after_commit on: :destroy do
      __elasticsearch__.delete_document
    end

    # index creation settings
    mapping dynamic: false do
      indexes :title, analyzer: :english
    end

    def self.search(query, from = 0)
      __elasticsearch__.search(
        {
          query: {
            match:
            {
              title: {
                query: query,
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
