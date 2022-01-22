class Category < ApplicationRecord
  has_many :books

  has_and_belongs_to_many :liking_users, class_name: 'User', join_table: 'categories_users',
                                         foreign_key: 'category_id'

  # model methods
  def recommendations(book)
    books.includes(:authors, :category, :metric_data).where.not(id: book.id)
         .limit(4).order(updated_at: :desc).sort_by(&:rank_score).reverse
  end
end
