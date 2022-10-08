class ElasticImportBooksJob < ApplicationJob
  queue_as :default

  def perform
    Book.where(created_at: 1.month.ago..).import
  end
end
