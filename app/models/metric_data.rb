class MetricData < ApplicationRecord
  belongs_to :book

  def update_book_metrics(field, action)
    send("update_#{field}", action)
    save
  end

  def score
    value = 0
    book_tiles = book.book_tiles.size
    { fav_books_count: 0.5,
      fav_entries_count: 0.9,
      upvotes_count: 0.75,
      downvotes_count: 0.75 }.each { |f, w| value += self[f] * w * book_tiles }
    value
  end

  private

  def update_fav_books(action)
    self.fav_books_count += 1 if action == :increase
    self.fav_books_count -= 1 if action == :decrease
  end

  def update_fav_entries(action)
    self.fav_entries_count += 1 if action == :increase
    self.fav_entries_count -= 1 if action == :decrease
  end

  def update_upvotes(action)
    self.upvotes_count += 1 if action == :increase
    self.upvotes_count -= 1 if action == :decrease
  end

  def update_downvotes(action)
    self.downvotes_count += 1 if action == :increase
    self.downvotes_count -= 1 if action == :decrease
  end
end
