class HomeController < ApplicationController
  def index
    return unless user_signed_in?

    @posts = Post.includes(:user, :likes, :comments)
                 .order(created_at: :desc)

    hashtags = Post.pluck(:content)
                   .join(" ")
                   .scan(/#\w+/)

    @trending_hashtags =
      hashtags
        .group_by(&:downcase)
        .transform_values(&:count)
        .sort_by { |_, count| -count }
        .first(10)
  end
end
