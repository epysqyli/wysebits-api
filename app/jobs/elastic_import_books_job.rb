class ElasticImportBooksJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false

  def perform
    Book.where(created_at: 1.month.ago..).import
  end
end
