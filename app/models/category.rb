class Category < ApplicationRecord
  has_many :books

  has_and_belongs_to_many :users, class_name: 'User', join_table: 'categories_users',
                                  foreign_key: 'category_id'
end
