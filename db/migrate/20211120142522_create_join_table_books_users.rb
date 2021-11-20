class CreateJoinTableBooksUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :books_users, id: false do |t|
      t.references :book, :user
    end

    add_index :books_users, %i[book_id user_id]
  end
end
