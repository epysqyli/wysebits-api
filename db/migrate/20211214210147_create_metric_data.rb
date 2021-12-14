class CreateMetricData < ActiveRecord::Migration[6.1]
  def change
    create_table :metric_data do |t|
      t.references :book, null: false, foreign_key: true
      t.integer :fav_books_count
      t.integer :fav_entries_count
      t.integer :upvotes_count
      t.integer :downvotes_count

      t.timestamps
    end
  end
end
