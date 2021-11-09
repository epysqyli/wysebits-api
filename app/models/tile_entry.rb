class TileEntry < ApplicationRecord
  belongs_to :book_tile
  has_many :comments, as: :commentable, dependent: :destroy
end
