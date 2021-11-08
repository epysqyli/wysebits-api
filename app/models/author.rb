class Author < ApplicationRecord
  has_and_belongs_to_many :books, join_table: 'authors_books', foreign_key: 'author_id'

  # model methods
  def self.find_or_create_author(params)
    full_name = Author.arel_table[:full_name]
    full_name_param = params[:author_full_name].split.map(&:capitalize).join(' ')
    results = Author.where(full_name.matches("%#{full_name_param}%"))

    if results.empty?
      Author.create! full_name: full_name_param
    else
      results.max_by { |author_i| author_i.books.size }
    end
  end
end
