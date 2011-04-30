$.Controller 'Dreamcatcher.Controllers.Comment',

  init: ->
    @currentUserId = parseInt $("#current_user_id_1").val()

    @entryView = $("#showEntry").length > 0
    if @entryView #Single-entry view
      @entryId = $('#showEntry').data 'id'
      @loadComments @entryId
    else #Stream view
      $(".thumb-1d").each (index,element) =>
        entry = $(element)
        newCount = @getNewCommentCount(entry)
        entryId = entry.data('id') 
        @loadComments entryId if newCount > 0

  #Helper Methods
  getEntry: (id) ->
    return $("#showEntry") if @entryView
    return $(".thumb-1d[data-id='#{id}']")#.filter(":data(id=#{id})").html()
    
  getEntryId: (el) ->
    return @entryId if @entryView
    return el.data('id') if el.hasClass("thumb-1d")
    return $(el.closest(".thumb-1d")).data('id')
    
  getEntryFromElement: (el) ->
    return $("#showEntry") if @entryView
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
    Dreamcatcher.Models.Comment.findEntryComments entryId,{},@callback('populateComments',entryId)
    
  populateComments: (entryId,comments) ->
    entry = @getEntry entryId
    newCount = @getNewCommentCount entry
    totalCount = comments.length
    commentsPanel = $(".commentsTarget",entry)
    commentsPanel.html @view('list',{userId: @currentUserId, newCount: newCount, totalCount: totalCount, comments: comments})
    
    #remove all delete buttons which should  not be accessed
    entryUserId = entry.data("userid")
    if @currentUserId isnt entryUserId or not $("#entryField").data 'owner'
      $(".deleteComment",commentsPanel).each (index,element) =>
        commentUserId = parseInt $(element).data('userid')
        $(element).remove() if commentUserId isnt @currentUserId
    
    commentsPanel.addClass("commentsPanel").addClass("wrapper").show()
    
    #TODO: hide loading wheel
    
    if @entryView #show all for entryView
      $(".prevCommentWrap",entry).show()
      #if not @entryView or (totalCount > 0 and newCount < totalCount) #show only new comments initially
    else #only show new ones, or at least 2
      $(entry).addClass("expanded")
      indexToStartShowing = totalCount - Math.max(newCount,2)
      $(".showAll",commentsPanel).show() if indexToStartShowing > 0 #only show showAll button if some left to show
      $(".prevCommentWrap",entry).each (index,element) ->
        $(element).show() if index >= indexToStartShowing

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
    else #if @getTotalCommentCount(entry) > 0
      @loadComments entryId
    #else
    #  @displayComments entry,0,0,{}
  
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
    #alert entryId
    Dreamcatcher.Models.Comment.create entryId,comment,@callback('created')