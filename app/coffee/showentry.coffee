
$(document).ready ->
  tagsController = new TagsController('.showTags', 'show')
  entry = new Entry '#showEntry'
  
# Model
class Entry
  constructor: (@name) ->
    @$currentEntry = $(@name)
    
    @setupComments()
    
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
    @$commentsInput.val('')
    comment = '<div class="prevCommentWrap hidden"><div class="avatar button round-12"></div><div class="prevComment input round-12"><div class="user button bevel round-8">' + currentUser + '</div><div class="postTime">1 seccond ago</div><div class="comment">' + commentText + '</div></div><div class="clear-both"></div></div>'
    
    @$commentsTarget.children().first().after(comment)
    $('.prevCommentWrap').slideDown()
