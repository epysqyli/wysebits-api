class CreateFavBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :fav_books do |t|
      t.belongs_to :user
      t.belongs_to :book
      t.timestamps
    end
  end
end
