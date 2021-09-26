class DropNetVotes < ActiveRecord::Migration[6.1]
  def change
    remove_column :book_tiles, :net_votes
  end
end
