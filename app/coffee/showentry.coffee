
$(document).ready ->
  tagsController = new TagsController('.showTags', 'show')

# Just because you're using objects doesn't mean you're writing good code.
# Just because you're writing in coffeescript, doesn't mean it will be compact and beautiful code.

# There is a point where using objects is just more obfuscation.

# If abstraction doesn't simplify, it's not worth it.

commentsPanel = $('#showEntry .commentsPanel')
commentsPanel.find('.save').click ->
  commentText = commentsPanel.find('.newComment textarea').val()
  commentsPanel.find('.target').children().first()
    .after('<div class="prevCommentWrap"><div class="avatar button round-12"></div><div class="prevComment input round-12"><div class="user button bevel round-8"></div><div class="postTime">1 second ago</div><div class="comment">' + commentText + '</div></div><div class="clear-both"></div></div>')
    .hide().slideDown()
  setTimeout(commentsPanel.find('.newComment textarea').val(''), 400)

#   entry = new Entry '#showEntry'
#   
# # Model
# class Entry
#   constructor: (@name) ->
#     @$currentEntry = $(@name)
#     
#     # @setupComments()
#     
#   setupComments: ->
#     comments = new Comments '#showEntry .commentsPanel'
# 
# 
# # Comments Model
# class Comments
#   constructor: (@name) ->
#     @$commentsContainer = $(@name)
#     @$commentsInput = @$commentsContainer.find('.newComment').find('textarea')
#     @$commentButton = @$commentsContainer.find('.save')
#     @$commentsTarget = @$commentsContainer.find('.target')
#       
#     @$commentButton.click (event) =>
#       @saveComment()
#       
#   saveComment: ->
#     currentUser = $('#contextPanel .context').text()
#     commentText = @$commentsInput.val()
#     @$commentsInput.val('')
#     comment = '<div class="prevCommentWrap hidden"><div class="avatar button round-12"></div><div class="prevComment input round-12"><div class="user button bevel round-8">' + currentUser + '</div><div class="postTime">1 second ago</div><div class="comment">' + commentText + '</div></div><div class="clear-both"></div></div>'
#     
#     @$commentsTarget.children().first().after(comment)
#     $('.prevCommentWrap').slideDown()


