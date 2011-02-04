module ApplicationHelper
  def friend_icon(subject, object, size)
    case subject.relationship_with(object)
    when :friend
      "friend-#{size}.png"
    when :following
      "friend-follower-#{size}.png"
    when :followed_by
      "friend-follow-#{size}.png"
    when :none
      "friend-none-#{size}.png"
    end
  end

  def coffee_script_include_tag(*sources)
    javascript_include_tag(*(sources.map { |js| "compiled/#{js}" }))
  end
  
  def sass_link_tag(*sources)
    stylesheet_link_tag(*(sources.map { |css| "compiled/#{css}" }))
  end
end
