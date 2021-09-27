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

ActiveRecord::Schema.define(version: 20_210_927_163_656) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'authors', force: :cascade do |t|
    t.string 'name'
    t.string 'surname'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  create_table 'authors_books', id: false, force: :cascade do |t|
    t.bigint 'author_id'
    t.bigint 'book_id'
    t.index %w[author_id book_id], name: 'index_authors_books_on_author_id_and_book_id'
    t.index ['author_id'], name: 'index_authors_books_on_author_id'
    t.index ['book_id'], name: 'index_authors_books_on_book_id'
  end

  create_table 'book_tiles', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.bigint 'book_id', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['book_id'], name: 'index_book_tiles_on_book_id'
    t.index ['user_id'], name: 'index_book_tiles_on_user_id'
  end

  create_table 'books', force: :cascade do |t|
    t.string 'title'
    t.date 'release_date'
    t.bigint 'category_id', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['category_id'], name: 'index_books_on_category_id'
  end

  create_table 'categories', force: :cascade do |t|
    t.string 'name'
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

  create_table 'relationships', force: :cascade do |t|
    t.integer 'follower_id'
    t.integer 'followed_id'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['followed_id'], name: 'index_relationships_on_followed_id'
    t.index %w[follower_id followed_id], name: 'index_relationships_on_follower_id_and_followed_id', unique: true
    t.index ['follower_id'], name: 'index_relationships_on_follower_id'
  end

  create_table 'subjects', force: :cascade do |t|
    t.string 'name'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  create_table 'subjects_books', id: false, force: :cascade do |t|
    t.bigint 'subject_id'
    t.bigint 'book_id'
    t.index ['book_id'], name: 'index_subjects_books_on_book_id'
    t.index %w[subject_id book_id], name: 'index_subjects_books_on_subject_id_and_book_id'
    t.index ['subject_id'], name: 'index_subjects_books_on_subject_id'
  end

  create_table 'tile_entries', force: :cascade do |t|
    t.text 'content'
    t.integer 'upvotes'
    t.integer 'downvotes'
    t.bigint 'book_tile_id', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['book_tile_id'], name: 'index_tile_entries_on_book_tile_id'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'name'
    t.string 'surname'
    t.string 'email_address'
    t.string 'password_digest'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  add_foreign_key 'book_tiles', 'books'
  add_foreign_key 'book_tiles', 'users'
  add_foreign_key 'books', 'categories'
  add_foreign_key 'tile_entries', 'book_tiles'
end
