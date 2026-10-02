class SavedPostsController < ApplicationController
  before_action :authenticate_user!

  def index
    redirect_to profile_path(anchor: "profile-saved")
  end

  def create
    post = Post.find(params[:post_id])

    current_user.saved_posts.find_or_create_by(post: post)

    redirect_back fallback_location: root_path,
                  notice: "Post saved successfully."
  end

  def destroy
    post = Post.find(params[:post_id])

    saved_post = current_user.saved_posts.find_by(post: post)
    saved_post&.destroy

    redirect_back fallback_location: root_path,
                  notice: "Post removed from saved."
  end
end
