class CreateSubjectsBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :subjects_books, id: false do |t|
      t.references :subject, :book
    end

    add_index :subjects_books, %i[subject_id book_id]
  end
end
