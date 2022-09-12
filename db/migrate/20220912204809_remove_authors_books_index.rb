class RemoveAuthorsBooksIndex < ActiveRecord::Migration[6.1]
  def change
    remove_index :authors_books, name: :index_authors_books_on_author_id_and_book_id
  end
end
