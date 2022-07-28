module UsersHelper
  def gravatar_for user, options = {size: Settings.user.gravatar_size}
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    size = options[:size]
    image_tag("https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}",
              alt: user.name, class: "gravatar")
  end
end
