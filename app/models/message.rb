class Message < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"

  validates :content, presence: true
  validates :content, length: { maximum: 1000 }
  validate :sender_cannot_message_themselves

  after_create_commit :broadcast_message

  private

  def sender_cannot_message_themselves
    if sender_id.present? && receiver_id.present? && sender_id == receiver_id
      errors.add(:receiver, "cannot be yourself")
    end
  end

  def broadcast_message
    ActionCable.server.broadcast(
      "messages",
      {
        sender_id: sender.id,
        receiver_id: receiver.id,
        sender: sender.profile&.username || sender.email,
        content: content,
        created_at: created_at.strftime("%I:%M %p")
      }
    )
  end
end