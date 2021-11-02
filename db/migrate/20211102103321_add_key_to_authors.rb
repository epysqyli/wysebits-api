class AddKeyToAuthors < ActiveRecord::Migration[6.1]
  def change
    add_column :authors, :key, :string
  end
end
