module EntriesHelper

  def gallery_list_item(image)
    small_image_url = image.url(:thumb)
    large_image_url = image.url(:medium)
    raw(%{
      <li class="lightbox" style="background: url(#{small_image_url}) no-repeat scroll center center transparent">
        <a href="#{large_image_url}"></a>
      </li>
    })
  end

  def youtube_link(link)
    raw(%{
      <li class="youtube" data-id="#{link.id}">
        <a target="_blank" style="background: no-repeat scroll center center transparent" href="#{link.url}">
          <img src="/images/icons/youtube-video-112.png" border="0">
        </a>
      </li>
    })
  end
  
  def youtube_embed(link)
    raw(%{
      <div id="#{link.id}" data-id="" class="youtubeEmbed"></div>
    })
  end

  def gallery_1d_thumb(image)
    small_image_url = image.url(:thumb, :size => 64)
    large_image_url = image.url(:medium)
    raw(%{
      <li style="background: url(#{small_image_url}) no-repeat top left">
        <a class="lightbox" href="#{large_image_url}"></a>
      </li>
    })
  end

  def gallery_1d_youtube(link)
    raw(%{
      <li class="youtube" data-id="#{link.id}">
        <a target="_blank" style="background: no-repeat scroll center center transparent" href="#{link.url}">
          <img src="/images/icons/youtube-video-48.png" border="0">
        </a>
      </li>
    })
  end

  
  def dream_header_url(image)
    image._?.url(:header)
  end
  
  def dreamfield_header_url(image)
    image._?.url(:dreamfield_header)
  end
  
  def dc_select_hour(datetime, options={}, html_options={})
    name = options[:field_name] || 'hour'
    name = "#{options[:prefix]}[#{name}]" if options[:prefix]
    hour = datetime.hour
    hour -= 12 if hour > 12
    raw(
      select_tag(name, options_for_select((1..12).map{|h| [h, h] }, hour), html_options )
    )
  end
  
  def dc_select_ampm(datetime, options={}, html_options={})
    name = options[:field_name] || 'ampm'
    name = "#{options[:prefix]}[#{name}]" if options[:prefix]
    hour = datetime.hour
    raw(
      select_tag(name, options_for_select(%w(am pm).map{|v| [v, v] }, (hour < 12) ? 'am' : 'pm'), html_options)
    )
  end
  
  def new_comments?(entry)
    entry.new_comment_count > 0 && entry.user == current_user
  end
end