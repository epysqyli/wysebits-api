class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  has_many :replies, class_name: 'Comment', foreign_key: 'commentable_id', as: :commentable, dependent: :destroy

  validates :content, presence: true

  def to_what
    case commentable_type
    when 'TileEntry'
      TileEntry.find(commentable_id)
    when 'Comment'
      Comment.find(commentable_id)
    end
  end
end
