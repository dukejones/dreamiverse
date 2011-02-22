
$(document).ready ->
  tagsController = new TagsController('.showTags', 'show')
  $('.gallery li a').lightBox();
  
  # Setup tag re-ordering
  $("#sorting").val(1)
  
  $("#tag-list").sortable ->
		distance: 10
		start: (event, ui) ->
		  $("#sorting").val(1) #// while sorting, change hidden value to 1
		stop: (event, ui) => $("#sorting").val(0)  #// on ending, change the value back to 0
		
	$( "#tag-list" ).bind "sortstart", (event, ui) ->
	  $("#sorting").val(0)
	  
	$( "#tag-list" ).bind "sortstop", (event, ui) ->
	  $("#sorting").val(1)
	
	# Setup comment expander
	$('textarea#comment_body').autoResize
	  animationDuration: 500
	  animate: true
	  extraSpace: 40
	  
  # setup links favico
  $('.link a').each ->
    if this.hostname && this.hostname != location.hostname
      $(this).before '<img class="attachedLink" src="http://' + this.hostname + '/favicon.ico" />'
      
      # Check for favico error
      $(".attachedLink").bind "error", ->
        $(this).attr('src', '/images/icons/link-16.gif')
    

# There is a point where using objects is just more obfuscation.

# If abstraction doesn't simplify, it's not worth it.
commentsPanel = $('#showEntry .commentsPanel')

$('form#new_comment').bind 'ajax:success', (event, xhr, status)->
  $('textarea', this).val('')
  
  # Update comment count
  newVal = parseInt($('.commentsHeader .counter').text()) + 1
  $('.commentsHeader .counter').text(newVal)
  
  commentsPanel.find('.target').children().last().prev().before(xhr).prev().hide().slideDown()


# TODO
#   # insert the failure message inside the "#account_settings" element
