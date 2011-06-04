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
  
  # Setup icon type changing
  # $('#entryType-list').unbind();
  #   $('#entryType-list').change( ->
  #     newSelection = $('#entryType-list').val()
  #     
  #     switch newSelection
  #       when "dream"
  #         iconFileSource = 'dream-24-active.png'
  #       when "vision"
  #         iconFileSource = 'vision-24-active.png'
  #       when "experience"
  #         iconFileSource = 'experience-24-active.png'
  #       when "article"
  #         iconFileSource = 'article-24-active.png'
  #         
  #     iconSource = 'url(/images/icons/' + iconFileSource + ') no-repeat center'
  #     
  #     $(this).prev().css('background', iconSource)
  #   )
  #$('#entryType-list').change()
  
  
  # If there are tags or images, expand them!
  if $('#currentImages').children().length > 1
    $('#attach-images').hide()
    $('.entryImages').slideDown(250)
  
  if $('#tag-list').children().length > 2
    $('#attach-tags').hide()
    $('.entryTags').slideDown(250)
  
  if $('#linkHolder').children().length > 0
    $('#attach-links').hide()
    $('.entryLinks').slideDown(250)
  
  # Check if location has been set and expand if so
  if $('.entryLocation').data('id')
    $('.entryLocation').slideDown(250)
    $('.entryLocation .data').show()
  
  # Check if emotions have been chosen, if so expand
  radioSelected = false
  $('.emotionPanel input[type="radio"]:checked').each (i, el) ->
    # only mark as selected if its a value other than 1
    if $(el).val() isnt '0'
      radioSelected = true
      $(el).parent().addClass('selected')

  if radioSelected
    $('#attach-emotions').hide()
    $('.entryEmotions').slideDown(250)
  
  # Check for youtube videos & get thumb/desc
  $('#linkHolder .youtube').each (i, el) =>
    # Pass the url and the element it came from
    getYoutubeEditData($(el).find('.linkUrlValue').val(), $(el))





  $('#entry_title').live "mouseenter", (event) =>
    if $('#entry_title').val() == ''
      $('#entry_title').attr(value: 'title', style: 'opacity: 0.4')

  $('#entry_title').live "focus", (event) =>
    if $('#entry_title').val() == 'title'
      $('#entry_title').attr(value: '', style: 'opacity: 1')

  $('#entry_title').live "mouseleave", (event) =>
    if $('#entry_title').val() == 'title'
      $('#entry_title').attr(value: '', style: 'opacity: 1')





  $('#entry_body').css('overflow','hidden')  
  
  # doing the focus stuff to make sure fitToContent gets called once on load 
  $('#entry_body').focus ->
    window.fitToContent(this, 0)
  $('#entry_body').focus()
  
  $('#entry_body').keyup ->
    window.fitToContent(this, 0)




  $('#entry_body').live "blur", (event) =>
    if $('#entry_body').val() == ''
      $('#title-hr').fadeOut('fast')
      $('#entry_body').slideUp('fast')
      $('#attach-text').show()

  $('#attach-text').live "click", (event) =>
    $('#entry_body').slideDown('fast')
    $('#title-hr').fadeIn('fast')



  # $('#entry_body').live "focus", (event) =>
  #   if $('#entry_title').val() == 'title'
  #     $('#entry_title').attr(value: '', style: 'opacity: 1')
  # 
  # $('#entry_body').live "mouseleave", (event) =>
  #   if $('#entry_title').val() == 'title'
  #     $('#entry_title').attr(value: '', style: 'opacity: 1')



  ### disabled until update entry ordering is working again
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
    tagsExist = false
	  $('#tag-list > .tag').each (i, el) ->
	    tagOrder.push($(this).data('id'))
	    tagsExist = true
    
    if tagsExist
	    entry = $('#showEntry').data('id')
	    order = tagOrder.join()
  ###
  
  # Hide the elements in the browsers they cant be seen in
  if window.BrowserDetect.browser is "Safari" or window.BrowserDetect.browser is "Chrome"
    $('.entryType').css('border', 'none')
    




  $('#entry_submit').click( (event) =>
    $('#entry_submit').addClass('selected')
    $('#postSpinner').removeClass('hidden')
  )


