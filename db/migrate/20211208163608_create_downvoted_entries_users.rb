class CreateDownvotedEntriesUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :downvoted_entries_users do |t|
      t.references :tile_entry, :user
      t.timestamps
    end
  end
end
