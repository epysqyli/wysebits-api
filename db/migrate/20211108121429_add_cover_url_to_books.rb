class AddCoverUrlToBooks < ActiveRecord::Migration[6.1]
  def change
    add_column :books, :cover_url, :text
  end
end
