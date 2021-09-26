class RemoveBookTitleColumnFromBookTile < ActiveRecord::Migration[6.1]
  def change
    remove_column :book_tiles, :book_title
  end
end
