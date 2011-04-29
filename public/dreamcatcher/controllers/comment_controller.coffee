$.Controller 'Dreamcatcher.Controllers.Comment',

  init: ->
    $(".entry_id").each (index,element) =>
      entryId = $(element).val()
      entry = @getEntryElement entryId
      newComments = @getNewComments entry
      Dreamcatcher.Models.Comment.findEntryComments entryId,{},@callback('populate') if newComments > 0
      $(entry).addClass("expanded")
      #$(".newCommentWrap").hide()

  getEntryElement: (id) ->
    return $("#entry_id_#{id}").closest(".thumb-1d")
    
  getEntryId: (el) ->
    return $(".entry_id",el.closest(".thumb-1d")).val()
    
  getNewComments: (entry) ->
    return parseInt $(".newComments",entry).val()

  getTotalComments: (entry) ->
    return parseInt $(".totalComments",entry).val()
    
  incrementComments: (entry) ->
    newComments = @getNewComments(entry)+1
    $(".newComments",entry).val(newComments)
    $(".count span",entry).text(newComments)
    $(".comment",entry).addClass("new") if not $(".comment").hasClass("new")
    
    totalComments = @getTotalComments(entry)+1
    $(".totalComments",entry).val(totalComments)
    $(".showAll span",entry).text(totalComments)

  populate: (comments) ->
    entryId = comments[0].entry_id if comments.length > 0
    entry = @getEntryElement entryId
    newComments = @getNewComments entry
    
    ##new method
    commentsContainer = $(".commentsPanel",entry)
    total = @getTotalComments entry
    commentsContainer.html @view('list',{newComments: newComments, totalComments: total, comments: comments})
    $(".showAll",commentsContainer).hide() if total is 0
    ##
    
    #TODO: show all if...
    $(".prevCommentWrap",entry).each (index,element) ->
      $(element).show() if index >= (total-newComments)

  created: (data) ->
    comment = data.comment
    comment.username = $(".rightPanel .user span").text().trim()
    entryId = comment.entry_id
    entry = @getEntryElement entryId
    $(".comments",entry).append(@view('show',comment))
    $(".prevCommentWrap:last",entry).show()
    
    $(".comment_body",entry).val ''
    $(".comment_body,.save",entry).removeAttr("disabled",false).removeClass("disabled")
    
    @incrementComments(entry)

  '.comment click': (el) ->
    entryId = @getEntryId el
    entry = @getEntryElement entryId
    ##new method
    total = @getTotalComments entry
    commentsContainer = $(".commentsPanel",entry)
    commentsContainer.html @view('list',{newComments: 0, totalComments: 0, comments: {}})
    $(".showAll",commentsContainer).hide() if total is 0 or total is new
    ##
  
  '.showAll click': (el) ->
    entryId = @getEntryId el
    entry = @getEntryElement entryId
    $(".prevCommentWrap",entry).show()
    $(".showAll").hide()
    
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