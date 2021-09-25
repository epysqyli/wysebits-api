class DropAuthorsBooksTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :authors_books
  end
end
