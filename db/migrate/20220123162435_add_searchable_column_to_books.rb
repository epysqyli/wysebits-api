class AddSearchableColumnToBooks < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      ALTER TABLE books
      ADD COLUMN searchable tsvector GENERATED ALWAYS AS (to_tsvector('english', title)) STORED;
    SQL
  end

  def down
    remove_column :books, :searchable
  end
end
