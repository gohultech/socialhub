class User < ApplicationRecord
  has_one :profile, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :active_follows,
           class_name: "Follow",
           foreign_key: :follower_id,
           dependent: :destroy

  has_many :following,
           through: :active_follows,
           source: :following

  has_many :passive_follows,
           class_name: "Follow",
           foreign_key: :following_id,
           dependent: :destroy

  has_many :followers,
           through: :passive_follows,
           source: :follower

  has_many :notifications,
           foreign_key: :recipient_id,
           dependent: :destroy

  has_many :saved_posts, dependent: :destroy

  has_many :saved,
           through: :saved_posts,
           source: :post

  has_many :conversation_users, dependent: :destroy
  has_many :conversations, through: :conversation_users
  has_many :messages, dependent: :destroy
  has_many :sent_messages,
           class_name: "Message",
           foreign_key: "sender_id",
           dependent: :destroy

  has_many :received_messages,
           class_name: "Message",
           foreign_key: "receiver_id",
           dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  after_create :create_default_profile

  private

  def create_default_profile
    create_profile!(
      username: email.split("@").first,
    )
  end
end
