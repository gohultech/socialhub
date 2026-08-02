class HashtagsController < ApplicationController

  def show
    @hashtag = params[:name]

    @posts = Post.where("content ILIKE ?", "%##{@hashtag}%")
                 .order(created_at: :desc)
  end

end