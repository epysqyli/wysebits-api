class ChangeColumnDefault < ActiveRecord::Migration[6.1]
  def change
    change_column_default :tile_entries, :upvotes, 0
    change_column_default :tile_entries, :downvotes, 0
  end
end
