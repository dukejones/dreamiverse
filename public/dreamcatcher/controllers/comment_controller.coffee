$.Controller 'Dreamcatcher.Controllers.Comment',

  init: ->
    $(".thumb-1d").each (index,element) =>
      entry = $(element)
      entryId = @getEntryId entry
      newComments = @getNewComments entry
      @loadComments entryId if newComments > 0

  getEntry: (id) ->
    return @getEntryFromElement $("#entry_id_#{id}")
    
  getEntryId: (el) ->
    return $(".entry_id",el) if el.hasClass(".thumb-1d")
    return $(".entry_id",@getEntryFromElement(el)).val()
    
  getEntryFromElement: (el) ->
    return el.closest(".thumb-1d")
    
  getNewComments: (entry) ->
    newComments = $(".newComments",entry).val()
    return parseInt newComments if newComments?
    return 0

  getTotalComments: (entry) ->
    return parseInt $(".totalComments",entry).val()
    
  changeCommentCount: (entry, difference) ->
    newComments = $(".newComments",entry).val()
    newComments = 0 if not newComments?
    newComments = newComments+difference
    $(".newComments",entry).val(newComments)
    $(".count span",entry).text(newComments)
    $(".comment",entry).addClass("new") if not $(".comment",entry).hasClass("new")
    
    totalComments = @getTotalComments(entry)+difference
    $(".totalComments",entry).val(totalComments)
    $(".showAll span",entry).text(totalComments)

  loadComments: (entryId) ->
    #show loading wheel
    Dreamcatcher.Models.Comment.findEntryComments entryId,{},@callback('populateComments')
    
  populateComments: (comments) ->
    entryId = comments[0].entry_id if comments.length > 0
    entry = @getEntry entryId
    newComments = @getNewComments entry
    totalComments = comments.length
    @displayComments entry,newComments,totalComments,comments
    
  displayComments: (entry, newComments, totalComments, comments) ->
    commentsPanel = $(".commentsTarget",entry)
    commentsPanel.html @view('list',{newComments: newComments, totalComments: totalComments, comments: comments})
    commentsPanel.addClass("commentsPanel").addClass("wrapper").show()
    
    #hide loading wheel
    $(entry).addClass("expanded")
    #alert "new:#{newComments} total:#{totalComments}"
    
    if (totalComments > 0 and newComments < totalComments) #show only new comments initially
      $(".showAll",commentsPanel).show()
      $(".prevCommentWrap",entry).each (index,element) ->
        $(element).show() if showAll or index >= (totalComments-newComments)
    else
      $(".prevCommentWrap",entry).show()

  created: (data) ->
    comment = data.comment
    comment.username = $(".rightPanel .user span").text().trim()
    entryId = comment.entry_id
    entry = @getEntry entryId
    $(".comments",entry).append @view('show',comment)
    $(".prevCommentWrap:last",entry).fadeIn()
    
    $(".comment_body",entry).val ''
    $(".comment_body,.save",entry).removeAttr("disabled",false).removeClass("disabled")
    
    @changeCommentCount(entry,1)

  '.comment click': (el) ->
    entry = @getEntryFromElement el
    entryId = @getEntryId entry
    
    if entry.hasClass("expanded") #currently expanded, so collapse
      $(".commentsTarget",entry).hide()
      entry.removeClass("expanded")
    else if $(".prevCommentWrap",entry).length > 0 #collapsed, been expanded, comments already loaded, just expand
      $(".commentsTarget",entry).show()
      entry.addClass("expanded")
    else if @getTotalComments(entry) > 0
      @loadComments entryId
    else
      @displayComments entry,0,0,{}
  
  '.showAll click': (el) ->
    entry = @getEntryFromElement el
    $(".prevCommentWrap",entry).show(), ->
      el.hide()
    
  '.deleteComment click': (el) ->
    entry = @getEntryFromElement el
    entryId = el.data 'entryid'
    commentId = el.data 'id'
    Dreamcatcher.Models.Comment.delete entryId,commentId
    el.closest('.prevCommentWrap').fadeOut 200, (element) =>
      $(element).remove()
      @changeCommentCount entry,-1
  
  '.save click': (el) ->
    $(".comment_body,.save",el.parent()).attr("disabled",true).addClass("disabled")
    comment = {
      user_id: $(".user_id",el.parent()).val()
      body: $(".comment_body",el.parent()).val()
    }
    entryId = @getEntryId el
    Dreamcatcher.Models.Comment.create entryId,comment,@callback('created')