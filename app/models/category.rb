class Category < ApplicationRecord
  has_many :books

  has_and_belongs_to_many :liking_users,
                          class_name: 'User',
                          join_table: 'categories_users',
                          foreign_key: 'category_id'

  validates :name, presence: true, uniqueness: true

  CATEGORIES = ['History',
                'Philosophy',
                'Religion and Spirituality',
                'Science',
                'Politics',
                'Social Sciences',
                'Essay',
                'Self-Help',
                'Business',
                'Economics and Finance',
                'Health and Wellness',
                'Crafts and Hobbies',
                'Academic Texts',
                'Language Books',
                'Arts Books',
                'Biographies',
                'Journalism',
                'Guides and How To Manuals',
                'Various',
                'Technology',
                'Memoirs'].freeze

  def recommendations
    return [] if slug == 'various'

    books.includes(:authors, :category, :metric_data)
         .order(updated_at: :desc).limit(5).sort_by(&:score).reverse
  end
end
