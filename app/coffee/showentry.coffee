
$(document).ready ->
  tagsController = new TagsController('.showTags', 'show')
  
  $('.gallery li a').lightBox();
  
  # setup links favico
  #
$('.link a').each ->
    if this.hostname && this.hostname != location.hostname
      $(this).before '<img src="' + this.hostname + '/favicon.ico"/>'
    

# There is a point where using objects is just more obfuscation.

# If abstraction doesn't simplify, it's not worth it.
commentsPanel = $('#showEntry .commentsPanel')

$('form#new_comment').bind 'ajax:success', (event, xhr, status)->
  $('textarea', this).val('')
  commentsPanel.find('.target').children().last().prev().before(xhr).prev().hide().slideDown()


# TODO
#   # insert the failure message inside the "#account_settings" element
