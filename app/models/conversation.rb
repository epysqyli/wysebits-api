class Conversation < ApplicationRecord
  attr_accessor :partner

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

  def other_user(user)
    user == sender ? recipient : sender
  end

  def append_partner(user)
    partner = other_user user
    self.partner = User.where(id: partner.id).select(:username, :id, :avatar_url).first
  end

  def last_message
    messages.order(created_at: :desc).first
  end

  def messages_count
    messages.size
  end
end
