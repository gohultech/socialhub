class User < ApplicationRecord
  has_one :profile, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  after_create :create_default_profile

  private

  def create_default_profile
    create_profile!(
      username: email.split("@").first,
    )
  end
end
