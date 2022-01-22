class RemoveKeyIndexFromAuthors < ActiveRecord::Migration[6.1]
  def change
    remove_index :authors, name: :index_authors_on_key
  end
end
