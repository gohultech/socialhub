class Profile < ApplicationRecord
  belongs_to :user

  has_one_attached :avatar
  has_one_attached :cover_photo

  validates :username, presence: true, uniqueness: true
  validate :avatar_must_be_supported_image
  validate :avatar_must_be_within_size_limit
  validate :cover_photo_must_be_supported_image
  validate :cover_photo_must_be_within_size_limit

  private

  def avatar_must_be_supported_image
    return unless avatar.attached?

    supported_types = %w[image/jpeg image/png image/webp image/gif]
    return if supported_types.include?(avatar.blob.content_type)

    errors.add(:avatar, "must be a JPG, PNG, WEBP, or GIF image")
  end

  def avatar_must_be_within_size_limit
    return unless avatar.attached? && avatar.blob.byte_size > 5.megabytes

    errors.add(:avatar, "must be smaller than 5 MB")
  end

  def cover_photo_must_be_supported_image
    return unless cover_photo.attached?

    supported_types = %w[image/jpeg image/png image/webp image/gif]
    return if supported_types.include?(cover_photo.blob.content_type)

    errors.add(:cover_photo, "must be a JPG, PNG, WEBP, or GIF image")
  end

  def cover_photo_must_be_within_size_limit
    return unless cover_photo.attached? && cover_photo.blob.byte_size > 5.megabytes

    errors.add(:cover_photo, "must be smaller than 5 MB")
  end
end
