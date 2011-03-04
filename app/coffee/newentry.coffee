getYoutubeEditData = (video_url, $linked_element) ->
  splitTextArray = video_url.split('v=');
  filePath = 'http://gdata.youtube.com/feeds/api/videos?q=' + splitTextArray[splitTextArray.length - 1] + '&alt=json&max-results=30&format=5';
  
  # Get the data from YOUTUBE
  $.ajax({
    url: filePath
    dataType: 'jsonp'
    success: (data) ->
      description = data.feed.entry[0].content.$t
      thumbnail_url = data.feed.entry[0].media$group.media$thumbnail[1].url
      
      $linked_element.find('.thumb').css('background-image', 'url(' + thumbnail_url + ')')
      $linked_element.find('.description').html(description)
  })

$(document).ready ->
  tagsController = new TagsController('.entryTags', 'edit')
  
  $('#entry_body').css('overflow','hidden')  
  
  # doing the focus stuff to make sure fitToContent gets called once on load 
  $('#entry_body').focus ->
    window.fitToContent(this, 0)
  $('#entry_body').focus()
  
  $('#entry_body').keyup ->
    window.fitToContent(this, 0)

  # Setup tag re-ordering
  $("#sorting").val(1)
  $("#tag-list").sortable -> distance: 30
		
	$( "#tag-list" ).bind "sortstart", (event, ui) ->
	  $("#sorting").val(0)
	  
	$( "#tag-list" ).bind "sortstop", (event, ui) ->
	  $("#sorting").val(1)
	  
	  # ONLY update tag sorting if editing an entry
	  if $('#entryField > form').hasClass('edit_entry')
	    tagOrder = []
  	  $('#tag-list > .tag').each (i, el) ->
  	    tagOrder.push($(this).data('id'))
	    
  	  entry = $('#showEntry').data('id')
  	  order = tagOrder.join()
  

  
  # Setup icon type changing
  $('#entryType_list').unbind();
  $('#entryType_list').change( ->
    newIcon = $(this).find('option:selected').css('background-image')
    newIconSrc = newIcon.slice(5, newIcon.length - 2)
    
    # get the larger icon path
    largeSelectionImage = newIconSrc.slice(0, newIconSrc.length-6) + '32.png'
    
    $(this).prev().attr('src', largeSelectionImage)
  )
  $('#entryType_list').change()
  


  
  # Hide the elements in the browsers they cant be seen in
  if window.BrowserDetect.browser is "Safari" or window.BrowserDetect.browser is "Chrome"
    $('.typeSelection, .listSelection').hide()
    $('.entryType').css('border', 'none')
  
  
  
  # If there are tags or images, expand them!
  if $('#currentImages').children().length > 1
    $('.entryAttach .images').hide()
    $('.entryImages').slideDown()
  
  if $('#tag-list').children().length > 2
    $('.entryAttach .tag').hide()
    $('.entryTags').slideDown()
  
  if $('#linkHolder').children().length > 0
    $('.entryAttach .links').hide()
    $('.entryLinks').slideDown()
  
  
  # Check for youtube videos & get thumb/desc
  $('#linkHolder .youtube').each (i, el) =>
    # Pass the url and the element it came from
    getYoutubeEditData($(el).find('.linkUrlValue').val(), $(el))
