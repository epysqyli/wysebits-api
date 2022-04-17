class RecommendedBooksJob < ApplicationJob
  include Redisable

  queue_as :default

  def perform
    Category::CATEGORIES.each do |category_name|
      category = Category.find_by_name(category_name)
      cache("#{category.slug}_recommendations", rank_recommendations(category))
    end
  end

  private

  def rank_recommendations(category)
    BookFormat.authors_category(category.recommendations)
  end
end
