class CreateCategoriesUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :categories_users do |t|
      t.references :category, :user
      t.timestamps
    end
  end
end
