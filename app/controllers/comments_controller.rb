class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @post = Post.find(params[:post_id])

    @comment = @post.comments.create(
      content: params[:comment][:content],
      user: current_user
    )

    Notification.create(
      recipient: @post.user,
      actor: current_user,
      action: "commented",
      notifiable: @comment
    ) unless @post.user == current_user

    redirect_back fallback_location: root_path
  end

  def edit
    @post = Post.find(params[:post_id])
    @comment = @post.comments.find(params[:id])
  end

  def update
    @post = Post.find(params[:post_id])
    @comment = @post.comments.find(params[:id])

    if @comment.update(comment_params)
      redirect_to root_path, notice: "Comment updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @comment = current_user.comments.find(params[:id])
    @comment.destroy

    redirect_back fallback_location: root_path,
                  notice: "Comment deleted successfully."
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end