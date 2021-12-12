class RemoveTileEntriesUsersHabtm < ActiveRecord::Migration[6.1]
  def change
    drop_table :tile_entries_users
  end
end
