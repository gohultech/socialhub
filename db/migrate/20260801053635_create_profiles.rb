class CreateProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :username
      t.string :full_name
      t.text :bio
      t.string :website
      t.string :location

      t.timestamps
    end
  end
end
