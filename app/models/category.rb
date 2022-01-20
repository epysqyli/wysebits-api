class Category < ApplicationRecord
  has_many :books

  has_and_belongs_to_many :liking_users, class_name: 'User', join_table: 'categories_users',
                                         foreign_key: 'category_id'

  # model methods
  def recommendations(book)
    books.where.not(id: book.id).order(updated_at: :desc).sort_by(&:rank_score).reverse.slice(0, 4)
  end
end
