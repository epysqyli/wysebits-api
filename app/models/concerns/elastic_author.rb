module ElasticAuthor
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
        indexes :full_name, type: :text
        indexes :key, type: :keyword
        indexes :books, type: :object do
          indexes :id, type: :long
          indexes :title, type: :text
          indexes :category, type: :object do
            indexes :id, type: :long
            indexes :name, type: :keyword
          end
        end
      end
    end

    def as_indexed_json
      as_json(
        only: %i[full_name key],
        include: [
          { books:
            { only: %i[id title], include:
              [{ category: { only: %i[id name] } }] } }
        ]
      )
    end

    def self.map_for_import(authors)
      Parallel.map(authors, in_threads: 2) { |author| { index: { _id: author.id, data: author.as_indexed_json } } }
    end

    def self.bulk_index(authors)
      __elasticsearch__.client.bulk({
                                      index: __elasticsearch__.index_name,
                                      type: '_doc',
                                      body: map_for_import(authors)
                                    })
    end

    def self.import
      includes(books: :category).find_in_batches do |authors|
        bulk_index(authors)
      end
    end
  end
end
