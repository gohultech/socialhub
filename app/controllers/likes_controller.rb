class LikesController < ApplicationController
  before_action :authenticate_user!

  def create
    @post = Post.find(params[:post_id])
    current_user.likes.find_or_create_by(post: @post)

    redirect_back fallback_location: root_path
  end

  def destroy
    @post = Post.find(params[:post_id])
    like = current_user.likes.find_by(post: @post)

    like&.destroy

    redirect_back fallback_location: root_path
  end
end