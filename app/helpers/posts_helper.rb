module PostsHelper

  def render_hashtags(text)
    text.gsub(/#\w+/) do |hashtag|
      link_to hashtag, hashtag_path(hashtag.delete("#"))
    end.html_safe
  end

  def render_mentions(text)
    text.gsub(/@\w+/) do |mention|
      username = mention.delete("@")
      user = User.joins(:profile).find_by(profiles: { username: username })

      if user
        link_to mention, user_path(user)
      else
        mention
      end
    end.html_safe
  end
end
