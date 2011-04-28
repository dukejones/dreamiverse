$.Controller 'Dreamcatcher.Controllers.Comment',

  init: ()
    #by default, get new comments only
    #{only_new: true}

  getEntryElement: (entryId) ->
    return $("#entry_id_#{entryId}").closest(".thumb-1d")

  populate: (comments) ->
    entryId = comments[0].entry_id if comments.length > 0
    entry = @getEntryElement entryId
    $(".comments",entry).html @view('list',{comments: comments})
        
  created: (data) ->
    comment = data.comment
    entryId = comment.entry_id
    entry = @getEntryElement entryId
    $(".comments",entry).append @view('show',comment)
    $(".comment_body",entry).val ''
        
  '.comment click': (el) ->
    entryId = $(".entry_id",el.parent()).val()
    Dreamcatcher.Models.Comment.findEntryComments entryId,{},@callback('populate')
    
  '.deleteComment click': (el) ->
    entryId = el.data 'entryid'
    commentId = el.data 'id'
    Dreamcatcher.Models.Comment.delete entryId,commentId
    el.closest('.prevCommentWrap').fadeOut 200
    
  '.save click': (el) ->
    comment = {
      user_id: $(".user_id",el.parent()).val()
      body: $(".comment_body",el.parent()).val()
    }
    entryId = $(".entry_id",el.closest(".thumb-1d")).val()
    Dreamcatcher.Models.Comment.create entryId,comment,@callback('created')