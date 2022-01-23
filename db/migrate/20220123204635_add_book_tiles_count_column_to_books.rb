class AddBookTilesCountColumnToBooks < ActiveRecord::Migration[6.1]
  def change
    add_column :books, :tiles_count, :integer, default: 0
  end
end
