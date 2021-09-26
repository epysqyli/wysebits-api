class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.bigint :commentable_id
      t.string :commentable_type
      t.bigint :user_id
      t.text :content

      t.timestamps
    end
  end
end
