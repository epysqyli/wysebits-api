class CreateUpvotedEntriesUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :upvoted_entries_users do |t|
      t.references :tile_entry, :user
      t.timestamps
    end
  end
end
