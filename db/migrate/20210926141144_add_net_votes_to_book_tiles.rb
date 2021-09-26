class AddNetVotesToBookTiles < ActiveRecord::Migration[6.1]
  def change
    add_column :book_tiles, :new_votes, :bigint
  end
end
