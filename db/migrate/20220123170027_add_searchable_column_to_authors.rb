class AddSearchableColumnToAuthors < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      ALTER TABLE authors
      ADD COLUMN searchable tsvector GENERATED ALWAYS AS (to_tsvector('english', full_name)) STORED;
    SQL
  end

  def down
    remove_column :authors, :searchable
  end
end
