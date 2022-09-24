class RemoveSearchableFromAuthors < ActiveRecord::Migration[6.1]
  def change
    remove_column :authors, :searchable
  end
end
