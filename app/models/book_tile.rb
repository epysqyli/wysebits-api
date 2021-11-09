class BookTile < ApplicationRecord
  belongs_to :user
  belongs_to :book
  has_many :tile_entries, dependent: :destroy
end
