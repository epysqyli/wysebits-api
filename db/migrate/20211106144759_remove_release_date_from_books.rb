class RemoveReleaseDateFromBooks < ActiveRecord::Migration[6.1]
  def change
    remove_column :books, :release_date
  end
end
