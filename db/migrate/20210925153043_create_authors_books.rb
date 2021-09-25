class CreateAuthorsBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :authors_books do |t|
      t.belongs_to :authors
      t.belongs_to :books
      t.timestamps
    end
  end
end
