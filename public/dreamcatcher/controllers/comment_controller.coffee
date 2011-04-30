$.Controller 'Dreamcatcher.Controllers.Comment',

  init: ->
    @currentUserId = parseInt $("#current_user_id_1").val()
    #Stream view
    $(".thumb-1d").each (index,element) =>
      entry = $(element)
      newCount = @getNewCommentCount(entry)
      entryId = entry.data('id') 
      @loadComments entryId if newCount > 0
    
    #Single-entry view
    if $("#showEntry")?
      @entryId = $('#showEntry').data 'id' if $('#showEntry')?
      @loadComments @entryId

  #Helper Methods
  getEntry: (id) ->
    return $("#showEntry") if $("#showEntry")?
    #TODO: Fix entry -- doesn't return
    $(".thumb-1d").each ->
      return $(this) if $(this).data('id') is id
    
  getEntryId: (el) ->
    return @entryId if $("#showEntry")?
    return $(".entry",el.closest(".thumb-1d")).data('id')
    
  getEntryFromElement: (el) ->
    return $("#showEntry") if $("#showEntry")?
    return el.closest(".thumb-1d")
    
  getNewCommentCount: (entry) ->
    newCount = $(".newComments",entry).val()
    newCount = 0 if not newCount?
    return parseInt newCount

  getTotalCommentCount: (entry) ->
    return $(".prevCommentWrap",entry).length
    
  updateCommentCount: (entry) ->
    #newCount = @getNewCommentCount(entry)+difference
    #$(".newComments",entry).val(newCount)
    #$(".comment .count span",entry).text(newCount)
    #$(".comment",entry).addClass("new") if not $(".comment",entry).hasClass("new")
    
    totalCount = @getTotalCommentCount(entry)
    $(".showAll span",entry).text(totalCount)
    $(".commentsHeader .count span",entry).text(totalCount)

  loadComments: (entryId) ->
    #show loading wheel
    Dreamcatcher.Models.Comment.findEntryComments entryId,{},@callback('populateComments')
    
  populateComments: (comments) ->
    entryId = comments[0].entry_id if comments.length > 0
    entry = @getEntry entryId
    alert(entry.html())
    newCount = @getNewCommentCount entry
    totalCount = comments.length
    @displayComments entry,newCount,totalCount,comments
    
  displayComments: (entry, newCount, totalCount, comments) ->
    commentsPanel = $(".commentsTarget",entry)
    commentsPanel.html @view('list',{userId: @currentUserId, newCount: newCount, totalCount: totalCount, comments: comments})
    
    #remove all delete buttons which should  not be accessed
    entryUserId = $entry.data("userid")
    alert entryUserId

    if @currentUserId isnt entryUserId or not $("#entryField").data 'owner'
      $(".deleteComment",commentsPanel).each ->
        commentUserId = parseInt $(this).data('userid')
        $(this).remove() if commentUserId isnt @currentUserId
    
    commentsPanel.addClass("commentsPanel").addClass("wrapper").show()
    
    #TODO: hide loading wheel
    $(entry).addClass("expanded")
    
    if not $("#showEntry")? or (totalCount > 0 and newCount < totalCount) #show only new comments initially
      indexToStartShowing = totalCount - Math.max(newCount,2) #show all new, or at least 2 --- TODO: This may change
      $(".showAll",commentsPanel).show() if indexToStartShowing > 0 #only show showAll button if some left to show
      $(".prevCommentWrap",entry).each (index,element) ->
        $(element).show() if index >= indexToStartShowing
    else #just show all of them!
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
    
    @updateCommentCount entry

  '.comment click': (el) ->
    entry = @getEntryFromElement el
    entryId = @getEntryId entry
    
    if entry.hasClass("expanded") #currently expanded, so collapse
      $(".commentsTarget",entry).hide()
      entry.removeClass("expanded")
    else if $(".prevCommentWrap",entry).length > 0 #collapsed, been expanded, comments already loaded, just expand
      $(".commentsTarget",entry).show()
      entry.addClass("expanded")
    else if @getTotalCommentCount(entry) > 0
      @loadComments entryId
    else
      @displayComments entry,0,0,{}
  
  '.showAll click': (el) ->
    entry = @getEntryFromElement el
    $(".prevCommentWrap",entry).show()
    el.hide()
    
  '.deleteComment click': (el) ->
    entry = @getEntryFromElement el
    entryId = el.data 'entryid'
    commentId = el.data 'id'
    Dreamcatcher.Models.Comment.delete entryId,commentId
    el.closest('.prevCommentWrap').fadeOut 200, (element) =>
      $(element).remove()
      @updateCommentCount entry
  
  '.save click': (el) ->
    $(".comment_body,.save",el.parent()).attr("disabled",true).addClass("disabled")
    entry = @getEntryFromElement el
    
    comment = {
      user_id: @currentUserId
      body: $(".comment_body",el.parent()).val()
    }
    entryId = @getEntryId el
    Dreamcatcher.Models.Comment.create entryId,comment,@callback('created')