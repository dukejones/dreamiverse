$.Controller 'Dreamcatcher.Controllers.Comment',

  init: ->
    #by default, get new comments only
    #{only_new: true}

  getEntryElement: (id) ->
    return $("#entry_id_#{id}").closest(".thumb-1d")
    
  getEntryId: (el) ->
    entryId = $(".entry_id",el.closest(".thumb-1d")).val()

  populate: (comments) ->
    entryId = comments[0].entry_id if comments.length > 0
    commentsContainer = $(".comments",@getEntryElement(entryId))
    commentsContainer.html @view('list',{comments: comments})
    commentsContainer.fadeIn 200
        
  created: (data) ->
    comment = data.comment
    entryId = comment.entry_id
    entry = @getEntryElement entryId
    $(".comments",entry).append @view('show',comment)
    $(".comment_body",entry).val ''
    count = parseInt $(".count span",entry).text().trim()
    $(".count span",entry).text count+1
    $(".comment_body,.save",entry).removeAttr("disabled",false).removeClass("disabled")
  
  '.showAll click': (el) ->
    entryId = @getEntryId el
    Dreamcatcher.Models.Comment.findEntryComments entryId,{},@callback('populate')
  
  #TODO new only
  '.comment click': (el) ->
    entryId = @getEntryId el
    Dreamcatcher.Models.Comment.findEntryComments entryId,{new_only:true},@callback('populate')
    
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