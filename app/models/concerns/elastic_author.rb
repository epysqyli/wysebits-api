module ElasticAuthor
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    settings index: { number_of_shards: 1 } do
      mapping dynamic: false do
        indexes :title
      end
    end
  end
end
