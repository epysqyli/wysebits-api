class CreateBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :books do |t|
      t.string :title
      t.date :release_date
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
