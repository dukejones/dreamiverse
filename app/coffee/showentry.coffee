
$(document).ready ->
  tagsController = new TagsController('.showTags', 'show')
  $('.gallery li a').lightBox();
  
  # Setup tag re-ordering
  $("#sorting").val(1)
  $("#tag-list").sortable -> distance: 10
		
	$( "#tag-list" ).bind "sortstart", (event, ui) ->
	  $("#sorting").val(0)
	  
	$( "#tag-list" ).bind "sortstop", (event, ui) ->
	  $("#sorting").val(1)
	  
	  tagOrder = []
	  $('#tag-list > .tag').each (i, el) ->
	    tagOrder.push($(this).data('id'))
	    
	  entry = $('#showEntry').data('id')
	  order = tagOrder.join()
	  
	  $.ajax {
      type: 'PUT'
      url: '/tags/sort_custom'
      data:
        entry_id: entry
        position_list: order
      #success: (data, status, xhr) => log "success"
    }
    
	  # $.ajax{
	  #      type: 'PUT'
	  #       url: '/tags/sort_custom_tags'
	  #       data:
	  #         entry_id: entry
	  #         position_list: order
	  #       success: (data, status, xhr) =>
	  #         log data
	  #         alert "SUCCESS!!"
	  #    }
#tags/sort_custom_tags= url, with the params: entry_id and position_list (your ordered list of ids) to it?
	     
	
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
