$.Controller 'Dreamcatcher.Controllers.Common.Comments', {
  pluginName: 'comments'
},{

  #TODO: [Architectual] Could abstract into Abstract class Comment, with StreamComment, and EntryComment inheriting.
  getView: (name, args) ->
    return $.View "/dreamcatcher/views/comments/#{name}.ejs", args

  init: (element) ->
    @element = $(element)
    @entryId = @element.data 'id'
    @entryView = @element.hasClass 'entry'
    @currentUserId = if $("#userInfo").exists() then parseInt $("#userInfo").data 'id' else null
    @currentUserImageId = parseInt $("#userInfo").data 'imageid'
    @loadComments() if @entryView or @getNewCommentCount() > 0
    
  getNewCommentCount: ->
    newCount = $(".newComments", @element).val()
    newCount = 0 if not newCount?
    return parseInt newCount

  getTotalCommentCount: ->
    commentsLoaded = $(".prevCommentWrap", @element).length
    return commentsLoaded if commentsLoaded > 0
      
    commentCountText = $(".comment .count span", @element).text().trim()
    return parseInt commentCountText if commentCountText.length > 0
    return 0
    
  updateCommentCount: ->
    totalCount = @getTotalCommentCount()
    
    $(".showAll span,.count span", @element).text totalCount
    $(".comment", @element).removeClass "new"
    
    if totalCount > 0
      $(".comment .count span", @element).text(totalCount).removeClass("empty")
    else
      $(".comment .count span", @element).text("").addClass("empty")
      

  loadComments: -> 
    comments_html = @getView 'init', {imageId: @currentUserImageId, entryId: @entryId, userId: @currentUserId}
    $(".commentsTarget", @element).addClass("commentsPanel wrapper").html(comments_html)
    $(".comments", @element).addClass("spinner") if @getTotalCommentCount() > 0
    Dreamcatcher.Models.Comment.findEntryComments @entryId, {}, @callback('populateComments')
    
  populateComments: (comments) ->
    totalCount = comments.length
    if @entryView
      if totalCount is 0 and @currentUserId is null
        $(".commentsTarget", @element).html("").removeClass("commentsPanel wrapper")
      else  
        numberToShow = totalCount
        $(".commentsHeader span", @element).text totalCount
    else
      $(".comment .count span", @element).text(totalCount) if not $(".comment", @element).hasClass("new") and totalCount > 0
      newCount = @getNewCommentCount()
      numberToShow = if newCount > 0 then newCount else 2   #show all 'new' items, or just latest 2
      numberToShow = Math.min totalCount, numberToShow       #make sure numberToShow does not exceed total
      @element.addClass "expanded"
      if numberToShow < totalCount
        $(".showAll span", @element).text totalCount
        $(".showAll", @element).show()
        
    list_html = @getView 'list',{ comments: comments, userId: @currentUserId, entryUserId: @element.data("userid"), numberToShow: numberToShow }
    $(".comments", @element).html(list_html)#.linkify().videolink()
    
    $(".comments", @element).removeClass("spinner")
    
  clearNewComments: ->
    if $(".comment", @element).hasClass("new")
      Dreamcatcher.Models.Comment.showEntry @entryId
      $(".comment", @element).removeClass "new" 
    @updateCommentCount()

  '.comment click': (el) ->
    if @element.hasClass("expanded")                 #currently expanded -> collapse
      @clearNewComments()
      $(".commentsTarget", @element).hide()
      @element.removeClass("expanded")
      
    else if $(".commentsPanel", @element).length > 0  #already been expanded -> re-expand
      $(".commentsTarget", @element).show()
      @element.addClass("expanded")
    
    else                                          #never been expanded -> populate    
      @loadComments()
  
  '.showAll click': (el) ->
    $(".prevCommentWrap", @element).show()
    el.hide()
    
  '.deleteComment click': (el) ->
    return if not confirm("confirm you want to delete this comment")    
    Dreamcatcher.Models.Comment.delete @entryId, el.data 'id'
    el.closest('.prevCommentWrap').remove()
    @updateCommentCount()
    
  '.comment_body focus': (el) ->
    if el.height() < 36
      el.animate { height: '36px' }, 'fast'
      $(".save", el.parent()).fadeIn 200, ->
        $(this).removeClass 'hidden'
          
  '.save click': (el) ->
    return if $(".comment_body", el.parent()).val().trim().length is 0
    $(".comment_body,.save", el.parent()).attr("disabled",true).addClass("disabled")
    
    Dreamcatcher.Models.Comment.create @entryId, {
      user_id: @currentUserId
      image_id: @currentUserImageId #TODO: not sure if image_id should be used like this
      body: $(".comment_body", el.parent()).val()
    }, @callback('created')
    
  created: (data) ->  
    comment = data.comment
    comment.username = $(".rightPanel .user span").text().trim()
    $(".comments", @element).append(
      @getView 'show',{
        comment: comment
        showDelete: true
        hidden: false
      })

    $(".prevCommentWrap:last", @element).show().linkify().videolink()

    $(".comment_body", @element).val ''
    $(".comment_body,.save", @element).removeAttr("disabled").removeClass("disabled")

    $(".comment_body", @element).animate({height: '24px'}, 'fast')
    $(".save", @element).fadeOut 200,->
      $(this).addClass("hidden")

    #@updateCommentCount entry
    @clearNewComments()
    
}