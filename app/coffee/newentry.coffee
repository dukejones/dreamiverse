
$(document).ready ->
  tagsController = new TagsController('.entryTags', 'edit')
  
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