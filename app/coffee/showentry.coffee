
$(document).ready ->
  tagsController = new TagsController('.showTags', 'show')
  
  $('.gallery li a').lightBox();

# There is a point where using objects is just more obfuscation.

# If abstraction doesn't simplify, it's not worth it.
commentsPanel = $('#showEntry .commentsPanel')

$('form#new_comment').bind 'ajax:success', (event, xhr, status)->
  $('textarea', this).val('')
  commentsPanel.find('.target').children().last().prev().before(xhr).prev().hide().slideDown()


# TODO
#   # insert the failure message inside the "#account_settings" element
