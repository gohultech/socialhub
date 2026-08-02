module PostsHelper

  def render_hashtags(text)
    text.gsub(/#\w+/) do |hashtag|
      link_to hashtag, hashtag_path(hashtag.delete("#"))
    end.html_safe
  end
end
