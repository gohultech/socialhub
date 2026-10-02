# frozen_string_literal: true

class AddConfirmableToUsers < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string
    add_index :users, :confirmation_token, unique: true

    # Existing accounts predate confirmation and must remain able to sign in.
    execute <<~SQL.squish
      UPDATE users
      SET confirmed_at = created_at
      WHERE confirmed_at IS NULL
    SQL
  end

  def down
    remove_index :users, :confirmation_token
    remove_column :users, :unconfirmed_email
    remove_column :users, :confirmation_sent_at
    remove_column :users, :confirmed_at
    remove_column :users, :confirmation_token
  end
end
