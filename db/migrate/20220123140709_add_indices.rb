class AddIndices < ActiveRecord::Migration[6.1]
  def change
    add_index :books, :category_id
  end
end
