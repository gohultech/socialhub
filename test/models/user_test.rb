require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "registration creates an unconfirmed user and sends confirmation instructions" do
    user = User.create!(
      email: "confirmation-#{SecureRandom.uuid}@example.test",
      password: "password123",
      password_confirmation: "password123"
    )

    assert_not user.confirmed?
    assert_not user.active_for_authentication?
    assert user.confirmation_token.present?

    email = ActionMailer::Base.deliveries.last
    assert_not_nil email
    assert_equal [user.email], email.to
    assert_includes email.subject, "Confirmation instructions"
    assert_includes email.body.encoded, user.confirmation_token
  end

  test "a valid confirmation token confirms the account" do
    user = create_unconfirmed_user

    confirmed_user = User.confirm_by_token(user.confirmation_token)

    assert_empty confirmed_user.errors
    assert confirmed_user.confirmed?
    assert confirmed_user.active_for_authentication?
  end

  test "an expired confirmation token does not confirm the account" do
    user = create_unconfirmed_user
    token = user.confirmation_token
    user.update_column(:confirmation_sent_at, 4.days.ago)

    confirmed_user = User.confirm_by_token(token)

    assert_not confirmed_user.confirmed?
    assert confirmed_user.errors.of_kind?(:email, :confirmation_period_expired)
  end

  private

  def create_unconfirmed_user
    User.create!(
      email: "confirmation-#{SecureRandom.uuid}@example.test",
      password: "password123",
      password_confirmation: "password123"
    )
  end
end
