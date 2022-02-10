require 'test_helper'

class BookTest < ActiveSupport::TestCase
  test 'should not save book without a title' do
    book = Book.new
    assert_not book.save, 'Saved book without title'
  end

  test "should print a book's title" do
    book = books(:test_book)

    assert_equal 'Some random title', book.title
  end
end
