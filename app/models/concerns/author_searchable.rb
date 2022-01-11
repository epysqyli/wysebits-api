module AuthorSearchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    def self.bulk_index(authors)
      __elasticsearch__.client.bulk({
                                      index: __elasticsearch__.index_name,
                                      type: '_doc',
                                      body: Parallel.map(authors, in_threads: 4) do |author|
                                              { index: { _id: author.id, data: author } }
                                            end
                                    })
    end

    def self.import
      in_batches { |authors| bulk_index(authors) }
    end

    mapping dynamic: false do
      indexes :full_name, analyzer: :standard
    end

    def self.search(query, from = 0)
      __elasticsearch__.search(
        {
          query: {
            match:
            {
              full_name: {
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
            fields: { full_name: {} }
          }
        }
      )
    end
  end
end
