class AddOpenLibraryColumnsToBooks < ActiveRecord::Migration[6.1]
  def change
    add_column :books, :ol_author_key, :string, after: 'title'
    add_column :books, :ol_key, :string, after: 'title'
  end
end
