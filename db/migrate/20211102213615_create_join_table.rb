class CreateJoinTable < ActiveRecord::Migration[6.1]
  def change
    create_table :authors_books, id: false do |t|
      t.references :author, :book
    end

    add_index :authors_books, %i[author_id book_id]
  end
end
