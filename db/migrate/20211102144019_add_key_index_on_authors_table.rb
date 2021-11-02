class AddKeyIndexOnAuthorsTable < ActiveRecord::Migration[6.1]
  def change
    add_index :authors, :key
  end
end
