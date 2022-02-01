class Category < ApplicationRecord
  has_many :books

  has_and_belongs_to_many :liking_users, class_name: 'User', join_table: 'categories_users',
                                         foreign_key: 'category_id'

  # model methods
  def recommendations(book)
    res = books.includes(:authors, :category,
                         :metric_data).limit(5).order(updated_at: :desc).sort_by(&:rank_score).reverse
    res.reject { |b| b.id == book.id }
  end
end
