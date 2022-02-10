require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  test 'history has one book' do
    history_category = categories(:history)

    assert_equal history_category.books.size, 1
  end
end
