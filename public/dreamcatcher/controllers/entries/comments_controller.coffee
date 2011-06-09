$.Controller 'Dreamcatcher.Controllers.Entries.Comments',

  #TODO: [Architectual] Could abstract into Abstract class Comment, with StreamComment, and EntryComment inheriting.
  getView: (name, args) ->
    return @view "//dreamcatcher/views/comments/#{name}.ejs", args

  init: ->
    @currentUserId = if $("#userInfo").exists() then parseInt $("#userInfo").data 'id' else null
    @currentUserImageId = parseInt $("#userInfo").data 'imageid'
        
  isEntryView: ->
    return $("#showEntry").is ':visible'
    
  load: (parentEl) ->
    if @isEntryView() #single entry view
      @loadComments parentEl, parentEl.data 'id'
    else #stream view
      $(".thumb-1d", parentEl).each (index,element) =>
        entry = $(element)
        newCount = @getNewCommentCount(entry)
        entryId = entry.data('id') 
        @loadComments entry, entryId if newCount > 0

  #Helper Methods
  getEntry: (id) ->
    return $("#showEntry .entry[data-id=#{id}]") if @isEntryView() 
    return $(".thumb-1d[data-id='#{id}']")
    
  getEntryId: (el) ->
    return el.closest('.entry').data 'id' if @isEntryView()
    return el.data 'id' if el.hasClass("thumb-1d")
    return el.closest(".thumb-1d").data 'id'
    
  getEntryFromElement: (el) ->
    return el.closest('.entry') if @isEntryView()
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
    totalCount = @getTotalCommentCount entry
    
    $(".showAll span,.count span",entry).text totalCount
    $(".comment",entry).removeClass "new"
    
    if totalCount > 0
      $(".comment .count span",entry).text(totalCount).removeClass("empty")
    else
      $(".comment .count span",entry).text("").addClass("empty")
      

  loadComments: (entry, entryId) -> 
    $(".commentsTarget",entry).addClass("commentsPanel wrapper").html(
      @getView 'init',{
        imageId: @currentUserImageId
        entryId: entryId
        userId: @currentUserId
      })
    $(".comments",entry).addClass("spinner") if @getTotalCommentCount(entry) > 0
    Dreamcatcher.Models.Comment.findEntryComments entryId,{},@callback('populateComments',entry,entryId)
    
  populateComments: (entry, entryId, comments) ->
    totalCount = comments.length
    if @isEntryView()
      if totalCount is 0 and @currentUserId is null
        $(".commentsTarget",entry).html("").removeClass("commentsPanel wrapper")
      else  
        numberToShow = totalCount
        $(".commentsHeader span",entry).text totalCount
    else
      $(".comment .count span",entry).text(totalCount) if not $(".comment",entry).hasClass("new") and totalCount > 0
      newCount = @getNewCommentCount entry
      numberToShow = if newCount > 0 then newCount else 2   #show all 'new' items, or just latest 2
      numberToShow = Math.min totalCount,numberToShow       #make sure numberToShow does not exceed total
      $(entry).addClass "expanded"
      if numberToShow < totalCount
        $(".showAll span",entry).text totalCount
        $(".showAll",entry).show()
        
    $(".comments",entry).html(
      @getView 'list',{
        comments: comments
        userId: @currentUserId
        entryUserId: entry.data("userid")
        numberToShow: numberToShow
      }
    ).linkify()
    
    $(".comments",entry).videolink()
    
    #linkify, and add youtube links
    
    $(".comments",entry).removeClass("spinner")

  created: (data) ->    
    comment = data.comment
    comment.username = $(".rightPanel .user span").text().trim()
    entryId = comment.entry_id
    entry = @getEntry entryId
    $(".comments",entry).append(
      @getView 'show',{
        comment: comment
        showDelete: true
        hidden: false
      })
    
    $(".prevCommentWrap:last",entry).show().linkify().videolink()
    
    $(".comment_body",entry).val ''
    $(".comment_body,.save",entry).removeAttr("disabled",false).removeClass("disabled")
    
    $(".comment_body",entry).animate({height: '24px'}, 'fast')
    $(".save", entry).fadeOut 200,->
      $(this).addClass("hidden")
    
    #@updateCommentCount entry
    @clearNewComments entry,entryId
    
    
  clearNewComments: (entry, entryId) ->
    if $(".comment",entry).hasClass("new")
      Dreamcatcher.Models.Comment.showEntry entryId
      $(".comment",entry).removeClass "new" 
    @updateCommentCount entry

  '.comment click': (el) ->
    entry = @getEntryFromElement el
    entryId = @getEntryId entry
    
    if entry.hasClass("expanded")                 #currently expanded -> collapse
      @clearNewComments entry,entryId
      $(".commentsTarget",entry).hide()
      entry.removeClass("expanded")
      
    else if $(".commentsPanel",entry).length > 0  #already been expanded -> re-expand
      $(".commentsTarget",entry).show()
      entry.addClass("expanded")
    
    else                                          #never been expanded -> populate    
      @loadComments entry,entryId
  
  '.showAll click': (el) ->
    entry = @getEntryFromElement el
    $(".prevCommentWrap",entry).show()
    el.hide()
    
  '.deleteComment click': (el) ->
    #text = "'"+$(".body",el.parent()).text()+"' ("+$(".commentTime",el.parent()).text()+")"
    return if not confirm("confirm you want to delete this comment")    
    entry = @getEntryFromElement el
    entryId = el.data 'entryid'
    commentId = el.data 'id'
    Dreamcatcher.Models.Comment.delete entryId,commentId
    el.closest('.prevCommentWrap').remove()
    @updateCommentCount entry
    
  '.comment_body focus': (el) ->
    if el.height() < 36
      el.animate({height: '36px'}, 'fast')
      $(".save", el.parent()).fadeIn 200,->
        $(this).removeClass("hidden")
          
  '.save click': (el) ->
    return if $(".comment_body",el.parent()).val().trim().length is 0
    $(".comment_body,.save",el.parent()).attr("disabled",true).addClass("disabled")
    entry = @getEntryFromElement el
    
    comment = {
      user_id: @currentUserId
      image_id: @currentUserImageId #TODO: not sure if image_id should be used like this
      body: $(".comment_body",el.parent()).val()
    }
    entryId = @getEntryId el
    Dreamcatcher.Models.Comment.create entryId,comment,@callback('created')