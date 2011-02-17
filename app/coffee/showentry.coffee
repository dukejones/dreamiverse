
$(document).ready ->
  tagsController = new TagsController('.showTags', 'show')
  
  $('.gallery li a').lightBox();

# There is a point where using objects is just more obfuscation.

# If abstraction doesn't simplify, it's not worth it.

$('form#new_comment').bind('ajax:success', (event, data)->
  $('textarea', this).val('')
  $('.prevCommentWrap').first().before(data).hide().slideDown()
)


# commentsPanel = $('#showEntry .commentsPanel')
# $('#showEntry .commentsPanel').live 'ajax:success', (event, xhr, status) =>
#   # insert the failure message inside the "#account_settings" element
#   commentsPanel.find('.target').children().first().after(xhr).next().hide().slideDown()
#   commentsPanel.find('.newComment textarea').val('')
  
  
  
