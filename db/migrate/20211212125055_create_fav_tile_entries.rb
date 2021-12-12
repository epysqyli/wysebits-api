class CreateFavTileEntries < ActiveRecord::Migration[6.1]
  def change
    create_table :fav_tile_entries do |t|
      t.belongs_to :user
      t.belongs_to :tile_entry
      t.timestamps
    end
  end
end
