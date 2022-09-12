class AddMissingIndicesToAuthorsBooks < ActiveRecord::Migration[6.1]
  def change
    add_index :authors_books, :author_id, name: 'author_id_index'
    add_index :authors_books, :book_id, name: 'book_id_index'
  end
end
