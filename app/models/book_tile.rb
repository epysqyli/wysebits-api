class BookTile < ApplicationRecord
  belongs_to :user
  belongs_to :book
end
