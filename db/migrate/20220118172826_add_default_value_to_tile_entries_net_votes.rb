class AddDefaultValueToTileEntriesNetVotes < ActiveRecord::Migration[6.1]
  def change
    change_column :tile_entries, :net_votes, :integer, default: 0
  end
end
