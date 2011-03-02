module EntriesHelper
  def gallery_list_item(image)
    small_image_url = image.url(:thumb, :size => 128)
    large_image_url = image.url(:medium)
    raw(%{
      <li class="lightbox" style="background: #ababab url(#{small_image_url}) no-repeat">
        <a href="#{large_image_url}"></a>
      </li>
    })
  end
  
  def dream_header_url(image)
    image._?.url(:header)
  end
  
  def dreamfield_header_url(image)
    image._?.url(:dreamfield_header)
  end
end