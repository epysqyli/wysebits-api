class AddIndexToSearchableAuthors < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :authors, :searchable, using: :gin, algorithm: :concurrently
  end
end
