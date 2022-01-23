class RemoveFurtherIndices < ActiveRecord::Migration[6.1]
  def change
    remove_index :subjects_books, name: :index_subjects_books_on_subject_id_and_book_id
    remove_index :relationships, name: :index_relationships_on_followed_id
  end
end
