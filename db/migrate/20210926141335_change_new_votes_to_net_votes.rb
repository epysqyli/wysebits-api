class ChangeNewVotesToNetVotes < ActiveRecord::Migration[6.1]
  def change
    rename_column :book_tiles, :new_votes, :net_votes
  end
end
