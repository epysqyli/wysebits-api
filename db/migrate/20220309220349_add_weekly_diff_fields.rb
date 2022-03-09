class AddWeeklyDiffFields < ActiveRecord::Migration[6.1]
  def change
    add_column :books, :previous_tiles_count, :integer, default: 0
    add_column :books, :tiles_count_diff, :integer, default: 0

    add_column :users, :tiles_count, :integer, default: 0
    add_column :users, :previous_tiles_count, :integer, default: 0
    add_column :users, :tiles_count_diff, :integer, default: 0

    add_column :tile_entries, :previous_upvotes, :integer, default: 0
    add_column :tile_entries, :upvotes_diff, :integer, default: 0
  end
end
