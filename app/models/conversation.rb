class Conversation < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  has_many :messages, dependent: :destroy

  validates_uniqueness_of :sender_id, scope: :recipient_id

  scope :between, lambda { |sender_id, recipient_id|
    where(sender_id: sender_id).and(where(recipient_id: recipient_id))
                               .or(where(sender_id: recipient_id).and(where(recipient_id: sender_id)))
  }

  def self.valid?(sender_id, recipient_id)
    between(sender_id, recipient_id).blank?
  end
end
