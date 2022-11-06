class ElasticImportBooksJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false

  INDEX_NAME_PREFIX = 'books-updated'.freeze

  def perform
    current_name = current_index_name
    Book.__elasticsearch__.create_index! index_name: new_index_name
    Book.import index_name: new_index_name
    update_elastic_config(new_index_name)
    Book.__elasticsearch__.delete_index! index: current_name
  end

  # private

  def es_config_yaml
    YAML.load_file ElasticBook::ELASTIC_CONFIG_FILE
  end

  def current_index_name
    es_config_yaml['current_index_name']['books']
  end

  def new_index_name
    iteration = current_index_name == 'books' ? 0 : current_index_name.split('-').last.to_i + 1
    "#{INDEX_NAME_PREFIX}-#{iteration}"
  end

  def update_elastic_config(new_index_name)
    es_config = es_config_yaml
    es_config['current_index_name']['books'] = new_index_name
    File.open(ElasticBook::ELASTIC_CONFIG_FILE, 'w') { |f| f.write es_config.to_yaml }
  end
end
