class CreateJoinTableTileEntriesUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :tile_entries_users, id: false do |t|
      t.references :tile_entry, :user
    end

    add_index :tile_entries_users, %i[tile_entry_id user_id]
  end
end
