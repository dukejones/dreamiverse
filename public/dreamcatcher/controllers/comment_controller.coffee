$.Controller 'Dreamcatcher.Controllers.Comment',

  populate: (comments) ->
    entryId = comments[0].entry_id if comments.length > 0
    commentView = @view('list',{comments: comments})
    $(".thumb-1d").each ->
      if $(this).find("#entry_id_#{entryId}").length > 0
        $(this).find(".comments").html commentView
        
  #remove: (commentId) ->
    
        

  '.comment click': (el) ->
    entryId = $(".entry_id",el.parent()).val()
    Dreamcatcher.Models.Comment.findEntryComments entryId,{},@callback('populate')
    
  '.deleteComment click': (el) ->
    entryId = el.data 'entryid'
    commentId = el.data 'id'
    alert entryId+' '+commentId
    Dreamcatcher.Models.Comment.delete entryId,commentId,@callback('remove')
    
  '#comment_submit': (el) ->
    params = {
      body: $('#comment_body').text()
      #entry_id: 
    }
    
