
$(document).ready ->
  tagsController = new TagsController('.entryTags', 'edit')
  
  # Setup tag re-ordering
  $("#sorting").val(1)
  $("#tag-list").sortable -> distance: 10
		
	$( "#tag-list" ).bind "sortstart", (event, ui) ->
	  $("#sorting").val(0)
	  
	$( "#tag-list" ).bind "sortstop", (event, ui) ->
	  $("#sorting").val(1)
	  # $.ajax {
	  #       type: 'PUT'
	  #       url: '/tags/sort_custom_tags'
	  #       data:
	  #         entry_id: @entryId()
	  #         what_id: @id
	  #       success: (data, status, xhr) =>
	  #         $.publish 'tags:removed', [@id]
        
        #tags/sort_custom_tags for the url, with the params: entry_id and position_list (your ordered list of ids) to it?
	  