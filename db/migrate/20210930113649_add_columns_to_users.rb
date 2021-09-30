class AddColumnsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :user, :confirmation_token, :string
    add_column :user, :confirmed_at, :datetime
    add_column :user, :confirmation_sent_at, :datetime
  end
end
