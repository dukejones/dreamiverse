$.Controller 'Dreamcatcher.Controllers.Comment',

  init: ->
    @currentUserId = parseInt $("#current_user_id_1").val()
    @entryView = $("#showEntry").length > 0
    
    if @entryView   #single-entry view
      @entryId = $('#showEntry').data 'id'
      @loadComments $('#showEntry'),@entryId
    else            #stream view
      $(".thumb-1d").each (index,element) =>
        entry = $(element)
        newCount = @getNewCommentCount(entry)
        entryId = entry.data('id') 
        @loadComments entry,entryId if newCount > 0

  #Helper Methods
  getEntry: (id) ->
    return $("#showEntry") if @entryView            #single entry 
    return $(".thumb-1d[data-id='#{id}']")          #stream
    
  getEntryId: (el) ->
    return @entryId if @entryView                   #single entry
    return el.data('id') if el.hasClass("thumb-1d") #stream
    return $(el.closest(".thumb-1d")).data('id')
    
  getEntryFromElement: (el) ->
    return $("#showEntry") if @entryView
    return el.closest(".thumb-1d")
    
  getNewCommentCount: (entry) ->
    newCount = $(".newComments",entry).val()
    newCount = 0 if not newCount?
    return parseInt newCount

  getTotalCommentCount: (entry) ->
    commentsLoaded = $(".prevCommentWrap",entry).length
    return commentsLoaded if commentsLoaded > 0
      
    commentCountText = $(".comment .count span",entry).text().trim()
    return parseInt commentCountText if commentCountText.length > 0
    return 0
    
  updateCommentCount: (entry) ->
    totalCount = @getTotalCommentCount(entry)
    
    $(".showAll span,.count span",entry).text(totalCount)
    $(".comment",entry).removeClass("new")
    
    if totalCount > 0
      $(".comment .count span",entry).text(totalCount).removeClass("empty")
    else
      $(".comment .count span",entry).text("").addClass("empty")
      

  loadComments: (entry,entryId) -> 
    $(".commentsTarget",entry).addClass("commentsPanel wrapper").html @view('init',{userId: @currentUserId})
    $(".comments",entry).addClass("spinner") if @getTotalCommentCount(entry) > 0
    Dreamcatcher.Models.Comment.findEntryComments entryId,{},@callback('populateComments',entry,entryId)
    
  populateComments: (entry,entryId,comments) ->
    $(".comments",entry).html(
      @view 'list', {
        comments: comments
        userId: @currentUserId
        entryUserId: entry.data("userid")
      }
    ).removeClass("spinner")
    
    #TODO: May need this for delete if @currentUserId isnt entryUserId or not $("#entryField").data 'owner'

    @updateCommentCount entry
    
    if @entryView
      $(".prevCommentWrap",entry).show()
      
    else #just show "new" comments (or the latest 2)
      newCount = @getNewCommentCount entry
      totalCount = @getTotalCommentCount entry
      
      $(entry).addClass("expanded")
      indexToStartShowing = totalCount - Math.max(newCount,2)
      $(".showAll",entry).show() if indexToStartShowing > 0 
      $(".prevCommentWrap",entry).each (index,element) ->
        $(element).show() if index >= indexToStartShowing

  created: (data) ->
    comment = data.comment
    comment.username = $(".rightPanel .user span").text().trim()
    entryId = comment.entry_id
    entry = @getEntry entryId
    $(".comments",entry).append(
      @view 'show',{
        comment: comment
        showDelete: true
      }
    )
    
    $(".prevCommentWrap:last",entry).show()
    
    $(".comment_body",entry).val ''
    $(".comment_body,.save",entry).removeAttr("disabled",false).removeClass("disabled")
    
    @updateCommentCount entry


  '.comment click': (el) ->
    entry = @getEntryFromElement el
    entryId = @getEntryId entry
    
    if entry.hasClass("expanded") #currently expanded, so collapse
      $(".commentsTarget",entry).hide()
      entry.removeClass("expanded")
    else if $(".commentsPanel",entry).length > 0
      $(".commentsTarget",entry).show()
      entry.addClass("expanded")
    else
      @loadComments entry,entryId
  
  '.showAll click': (el) ->
    entry = @getEntryFromElement el
    $(".prevCommentWrap",entry).show()
    el.hide()
    
  '.deleteComment click': (el) ->
    entry = @getEntryFromElement el
    entryId = el.data 'entryid'
    commentId = el.data 'id'
    Dreamcatcher.Models.Comment.delete entryId,commentId
    el.closest('.prevCommentWrap').fadeOut 200
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