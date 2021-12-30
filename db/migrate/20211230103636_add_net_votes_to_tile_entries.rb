class AddNetVotesToTileEntries < ActiveRecord::Migration[6.1]
  def change
    add_column :tile_entries, :net_votes, :integer
  end
end
