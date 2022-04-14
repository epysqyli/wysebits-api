class Category < ApplicationRecord
  has_many :books

  has_and_belongs_to_many :liking_users, class_name: 'User', join_table: 'categories_users',
                                         foreign_key: 'category_id'

  validates :name, presence: true, uniqueness: true

  # model methods
  def recommendations(book)
    return [] if book.category.slug == 'various'

    books.includes(:authors, :category, :metric_data).where.not(id: book.id)
         .order(updated_at: :desc).limit(4).sort_by(&:score).reverse
  end
end
