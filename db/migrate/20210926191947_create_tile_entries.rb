class CreateTileEntries < ActiveRecord::Migration[6.1]
  def change
    create_table :tile_entries do |t|
      t.text :content
      t.integer :upvotes
      t.integer :downvotes
      t.references :book_tile, null: false, foreign_key: true

      t.timestamps
    end
  end
end
