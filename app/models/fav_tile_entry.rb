class FavTileEntry < ApplicationRecord
  belongs_to :user
  belongs_to :tile_entry
end
