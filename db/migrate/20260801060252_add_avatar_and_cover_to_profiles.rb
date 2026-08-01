class AddAvatarAndCoverToProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :avatar, :string
    add_column :profiles, :cover_image, :string
  end
end
