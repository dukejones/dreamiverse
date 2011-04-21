###
#LEGACY CODE!

$(document).ready ->
  setupMetaDropdowns()
  
window.setupMetaDropdowns = ->
  


  

  # setup fb unlink UI update
  $('#fbLink').bind 'ajax:success', (event, xhr, status)->
    newElement = '<a id="fbLink" href="/auth/facebook" class="linkAccount">link account</a>'

    #remove old link
    $('#fbLink').remove()
    
    #display new link
    $('.network').append(newElement)
  
  # setup change password fields
  $('form#change_password').bind 'ajax:beforeSend', (xhr, settings)->
    $('.changePassword .target').hide()

  
  $('form#change_password').bind 'ajax:success', (data, xhr, status)->
    $('p.notice').text(xhr.message)
    if xhr.errors
      for error, message of xhr.errors
        $('#user_' + error).prev().text(message[0])
      # open the panel back up
      $('.changePassword .target').slideDown(250)
    else
      $('#change_password .error').text('')
      $('#user_old_password, #user_password, #user_password_confirmation').val('')
  
  $('form#change_password').bind 'ajax:error', (xhr, status, error)->
    #$('p.alert').text(xhr.error)
    log xhr.errors
###
