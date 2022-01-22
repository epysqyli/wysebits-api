class RemoveUnnecessaryIndices < ActiveRecord::Migration[6.1]
  def change
    remove_index :authors_books, name: :index_authors_books_on_author_id
    remove_index :authors_books, name: :index_authors_books_on_book_id
    remove_index :book_tiles, name: :index_book_tiles_on_user_id
    remove_index :books, name: :index_books_on_category_id
    remove_index :categories, name: :index_categories_on_slug
    remove_index :categories_users, name: :index_categories_users_on_category_id
    remove_index :categories_users, name: :index_categories_users_on_user_id
    remove_index :downvoted_entries_users, name: :index_downvoted_entries_users_on_tile_entry_id
    remove_index :downvoted_entries_users, name: :index_downvoted_entries_users_on_user_id
    remove_index :fav_books, name: :index_fav_books_on_book_id
    remove_index :fav_books, name: :index_fav_books_on_user_id
    remove_index :fav_tile_entries, name: :index_fav_tile_entries_on_tile_entry_id
    remove_index :fav_tile_entries, name: :index_fav_tile_entries_on_user_id
    remove_index :metric_data, name: :index_metric_data_on_book_id
    remove_index :relationships, name: :index_relationships_on_follower_id_and_followed_id
    remove_index :relationships, name: :index_relationships_on_follower_id
    remove_index :subjects_books, name: :index_subjects_books_on_book_id
    remove_index :subjects_books, name: :index_subjects_books_on_subject_id
    remove_index :temporary_entries, name: :index_temporary_entries_on_book_tile_id
    remove_index :upvoted_entries_users, name: :index_upvoted_entries_users_on_tile_entry_id
    remove_index :upvoted_entries_users, name: :index_upvoted_entries_users_on_user_id
  end
end
