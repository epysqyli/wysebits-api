# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20_220_123_141_333) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'active_storage_attachments', force: :cascade do |t|
    t.string 'name', null: false
    t.string 'record_type', null: false
    t.bigint 'record_id', null: false
    t.bigint 'blob_id', null: false
    t.datetime 'created_at', null: false
    t.index ['blob_id'], name: 'index_active_storage_attachments_on_blob_id'
    t.index %w[record_type record_id name blob_id], name: 'index_active_storage_attachments_uniqueness',
                                                    unique: true
  end

  create_table 'active_storage_blobs', force: :cascade do |t|
    t.string 'key', null: false
    t.string 'filename', null: false
    t.string 'content_type'
    t.text 'metadata'
    t.string 'service_name', null: false
    t.bigint 'byte_size', null: false
    t.string 'checksum', null: false
    t.datetime 'created_at', null: false
    t.index ['key'], name: 'index_active_storage_blobs_on_key', unique: true
  end

  create_table 'active_storage_variant_records', force: :cascade do |t|
    t.bigint 'blob_id', null: false
    t.string 'variation_digest', null: false
    t.index %w[blob_id variation_digest], name: 'index_active_storage_variant_records_uniqueness', unique: true
  end

  create_table 'authors', force: :cascade do |t|
    t.string 'full_name'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.string 'key'
  end

  create_table 'authors_books', id: false, force: :cascade do |t|
    t.bigint 'author_id'
    t.bigint 'book_id'
    t.index %w[author_id book_id], name: 'index_authors_books_on_author_id_and_book_id'
  end

  create_table 'book_tiles', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.bigint 'book_id', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['book_id'], name: 'index_book_tiles_on_book_id'
  end

  create_table 'books', force: :cascade do |t|
    t.string 'title'
    t.bigint 'category_id', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.string 'ol_author_key'
    t.string 'ol_key'
    t.text 'cover_url'
    t.index ['category_id'], name: 'index_books_on_category_id'
  end

  create_table 'categories', force: :cascade do |t|
    t.string 'name'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.string 'slug'
  end

  create_table 'categories_users', force: :cascade do |t|
    t.bigint 'category_id'
    t.bigint 'user_id'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  create_table 'comments', force: :cascade do |t|
    t.bigint 'commentable_id'
    t.string 'commentable_type'
    t.bigint 'user_id'
    t.text 'content'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  create_table 'downvoted_entries_users', force: :cascade do |t|
    t.bigint 'tile_entry_id'
    t.bigint 'user_id'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  create_table 'fav_books', force: :cascade do |t|
    t.bigint 'user_id'
    t.bigint 'book_id'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  create_table 'fav_tile_entries', force: :cascade do |t|
    t.bigint 'user_id'
    t.bigint 'tile_entry_id'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  create_table 'metric_data', force: :cascade do |t|
    t.bigint 'book_id', null: false
    t.integer 'fav_books_count'
    t.integer 'fav_entries_count'
    t.integer 'upvotes_count'
    t.integer 'downvotes_count'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  create_table 'relationships', force: :cascade do |t|
    t.integer 'follower_id'
    t.integer 'followed_id'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  create_table 'subjects', force: :cascade do |t|
    t.string 'name'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  create_table 'subjects_books', id: false, force: :cascade do |t|
    t.bigint 'subject_id'
    t.bigint 'book_id'
  end

  create_table 'temporary_entries', force: :cascade do |t|
    t.bigint 'book_tile_id', null: false
    t.text 'content'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  create_table 'tile_entries', force: :cascade do |t|
    t.text 'content'
    t.integer 'upvotes', default: 0
    t.integer 'downvotes', default: 0
    t.bigint 'book_tile_id', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.integer 'net_votes', default: 0
    t.index ['book_tile_id'], name: 'index_tile_entries_on_book_tile_id'
  end

  create_table 'upvoted_entries_users', force: :cascade do |t|
    t.bigint 'tile_entry_id'
    t.bigint 'user_id'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  create_table 'users', force: :cascade do |t|
    t.string 'name'
    t.string 'surname'
    t.string 'email_address'
    t.string 'password_digest'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.string 'confirmation_token'
    t.datetime 'confirmed_at'
    t.datetime 'confirmation_sent_at'
    t.string 'username'
    t.text 'avatar_url'
  end

  add_foreign_key 'active_storage_attachments', 'active_storage_blobs', column: 'blob_id'
  add_foreign_key 'active_storage_variant_records', 'active_storage_blobs', column: 'blob_id'
  add_foreign_key 'book_tiles', 'books'
  add_foreign_key 'book_tiles', 'users'
  add_foreign_key 'books', 'categories'
  add_foreign_key 'metric_data', 'books'
  add_foreign_key 'temporary_entries', 'book_tiles'
  add_foreign_key 'tile_entries', 'book_tiles'
end
