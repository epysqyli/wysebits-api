class CreateTemporaryEntries < ActiveRecord::Migration[6.1]
  def change
    create_table :temporary_entries do |t|
      t.references :book_tile, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
