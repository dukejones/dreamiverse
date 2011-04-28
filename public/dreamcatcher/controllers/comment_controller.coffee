$.Controller 'Dreamcatcher.Controllers.Comment',

  init: ->
    $(".entry_id").each (index,element) =>
      entryId = $(element).val()
      entry = @getEntryElement entryId
      newComments = @getNewComments entry
      Dreamcatcher.Models.Comment.findEntryComments entryId,{},@callback('populate') if newComments > 0
      total = @getTotalComments entry
      #log newComments+' '+total
      if total is 0
        $(".showAll",entry).hide()
        log entryId
      # if total is 0# or total is newComments
        

  getEntryElement: (id) ->
    return $("#entry_id_#{id}").closest(".thumb-1d")
    
  getEntryId: (el) ->
    return $(".entry_id",el.closest(".thumb-1d")).val()
    
  getNewComments: (entry) ->
    return parseInt $(".newComments",entry).val()
    
  getTotalComments: (entry) ->
    return parseInt $(".totalComments",entry).val()

  populate: (comments) ->
    entryId = comments[0].entry_id if comments.length > 0
    entry = @getEntryElement entryId
    newComments = @getNewComments entry
    commentsContainer = $(".comments",entry)
    commentsContainer.html @view('list',{comments: comments})
    
    #show new comments only
    $(".prevCommentWrap",entry).each (index,element) ->
      $(element).show() if index < newComments

  created: (data) ->
    comment = data.comment
    entryId = comment.entry_id
    entry = @getEntryElement entryId
    $(".comments",entry).append @view('show',comment)
    $(".comment_body",entry).val ''
    $(".count span",entry).text @getCommentCount(entry)+1
    $(".comment_body,.save",entry).removeAttr("disabled",false).removeClass("disabled")
  
  '.showAll click': (el) ->
    entryId = @getEntryId el
    entry = @getEntryElement entryId
    $(".prevCommentWrap",entry).show()
    
  '.deleteComment click': (el) ->
    entryId = el.data 'entryid'
    commentId = el.data 'id'
    Dreamcatcher.Models.Comment.delete entryId,commentId
    el.closest('.prevCommentWrap').fadeOut 200
    
  '.save click': (el) ->
    $(".comment_body,.save",el.parent()).attr("disabled",true).addClass("disabled")
    comment = {
      user_id: $(".user_id",el.parent()).val()
      body: $(".comment_body",el.parent()).val()
    }
    entryId = @getEntryId el
    Dreamcatcher.Models.Comment.create entryId,comment,@callback('created')