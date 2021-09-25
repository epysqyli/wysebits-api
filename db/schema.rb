ActiveRecord::Schema.define(version: 20_210_925_114_911) do
  enable_extension 'plpgsql'

  create_table 'users', force: :cascade do |t|
    t.string 'name'
    t.string 'surname'
    t.string 'email_address'
    t.string 'password_digest'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end
end
