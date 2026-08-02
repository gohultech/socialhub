class FollowsController < ApplicationController
  before_action :authenticate_user!

  def create
    user = User.find(params[:user_id])

    current_user.active_follows.create(following: user)

    Notification.create(
      recipient: @user,
      actor: current_user,
      action: "followed",
      notifiable: current_user
    ) unless @user == current_user

    redirect_back fallback_location: root_path,
                  notice: "You are now following #{user.profile&.username || user.email}."
  end

  def destroy
    user = User.find(params[:user_id])

    follow = current_user.active_follows.find_by(following: user)
    follow&.destroy

    redirect_back fallback_location: root_path,
                  notice: "You unfollowed #{user.profile&.username || user.email}."
  end
end