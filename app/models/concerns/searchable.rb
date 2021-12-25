module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    def self.import
      includes(:category, :authors).find_in_batches do |books|
        bulk_index(books)
      end
    end

    def self.bulk_index(books)
      __elasticsearch__.client.bulk({
                                      index: __elasticsearch__.index_name,
                                      type: '_doc',
                                      body: map_for_import(books)
                                    })
    end

    def map_for_import(books)
      books.map { |book| { index: { _id: book.id, data: book.as_indexed_json } } }
    end

    settings index: { number_of_shards: 2 } do
      mapping dynamic: false do
        indexes :title, analyzer: :english
        indexes :category, type: 'nested' do
          indexes :name, analyzer: :english
        end
        indexes :authors, type: 'nested' do
          indexes :full_name, analyzer: :standard
        end
      end
    end

    def as_indexed_json(_options = {})
      as_json(include: %i[authors category])
    end

    def self.search(query, from = 0)
      __elasticsearch__.search(
        {
          query: {
            multi_match:
            {
              query: query,
              fields: %w[title authors category],
              fuzziness: 'AUTO'
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
