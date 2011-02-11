
$(document).ready ->
  setupEntry()
  
# attaching to window object means it can be accessed outside of the enclosing closure.
window.setupEntry = ->
  entry = new Entry '#showEntry'
  
# Model
class Entry
  constructor: (@name) ->
    @$currentEntry = $(@name)
    
    @setupTags()
    @setupComments()
  
  setupTags: ->
    tagSystem = new Tag '.entryTags'
    
  setupComments: ->
    comments = new Comments '#showEntry .commentsPanel'


# Comments Model
class Comments
  constructor: (@name) ->
    @$commentsContainer = $(@name)
    @$commentsInput = @$commentsContainer.find('.newComment').find('textarea')
    @$commentButton = @$commentsContainer.find('.save')
    @$commentsTarget = @$commentsContainer.find('.target')
      
    @$commentButton.click (event) =>
      @saveComment()
      
  saveComment: ->
    currentUser = $('#contextPanel .context').text()
    commentText = @$commentsInput.val()
    comment = '<div class="prevCommentWrap hidden"><div class="avatar button round-12"></div><div class="prevComment input round-12"><div class="user button bevel round-8">' + currentUser + '</div><div class="postTime">right now</div><div class="comment">' + commentText + '</div></div><div class="clear-both"></div></div>'
    
    @$commentsTarget.children().last().before(comment)
    $('.prevCommentWrap').slideDown()

# Tag Model
class Tag
  constructor: (@name) ->
    @$tagContainer = $(@name)
    @$tagHeader = @$tagContainer.find('.tagHeader')
    @$tagsExpand = @$tagContainer.find('.target')
    @$tagsList = @$tagContainer.find('.tag-list')
    @$tagInput = @$tagContainer.find('#newTag')
    @$tagInputWrap = @$tagContainer.find('.tagInputWrap')
    @$tagAddButton = @$tagContainer.find('.tagAdd')
    @$tagCheck = @$tagContainer.find('.tagCheck')
    @$tagEntryButton = @$tagContainer.find('.tagThisEntry')
    
    $.subscribe 'tagToggle', (event) =>
      @toggleView()

    @$tagHeader.click (event) =>
      $.publish('tagToggle', [this])
    
    @$tagAddButton.click (event) =>
      @addTag()
    
    @$tagInput.keypress (event) =>
      if event.which is 13
        @addTag()
    
    if @$tagEntryButton
      @$tagEntryButton.click (event) =>
        @enableTags()
      
  enableTags: ->
    @$tagEntryButton.hide()
    
    @$tagCheck.unbind()
    @$tagCheck.click (event) =>
      @disableTags()
    
    @$tagCheck.show()
    @$tagInputWrap.show()
    
    @$tagInput.focus()
  
  disableTags: ->
    @$tagCheck.hide()
    @$tagInputWrap.hide()
    
    @$tagEntryButton.show()
    
  toggleView: ->
    if @$tagsList.is(":visible")
      @contract()
    else
      @expand()
    
  expand: ->
    # code to expand menu item
    @$tagsExpand.slideDown()
    
  contract: ->
    # code to contract menu item
    @$tagsExpand.slideUp()
    
  addTag: ->
    randomNumber = Math.round( Math.random() * 100001)
    @tagID = ('tagID_' + randomNumber)
    
    if @$tagInput.val()
      tagNode = $('#empty-tag').clone().attr('id', @tagID );
      @$tagsList.find('br').before(tagNode);
      tagNode.removeClass('hidden').find('.content').html(@$tagInput.val())
      tagNode.css('background-color', '#ccc');
      
      # todo : this function is not running
      setTimeout( => 
        tagNode.animate({backgroundColor: "#333"}, 'slow')
      , 200)
      
      @$tagInput.val('')
      @$tagInput.focus()
    
    