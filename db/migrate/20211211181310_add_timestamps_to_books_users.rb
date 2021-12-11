class AddTimestampsToBooksUsers < ActiveRecord::Migration[6.1]
  def change
    add_timestamps :books_users, null: false, default: -> { 'NOW()' }
  end
end
