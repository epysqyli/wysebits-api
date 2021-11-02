class ChangeAuthorColumns < ActiveRecord::Migration[6.1]
  def change
    remove_column :authors, :surname
    rename_column :authors, :name, :full_name
  end
end
