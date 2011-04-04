$(document).ready ->
  $('#new_user').submit( ->
    if $('#user_seed_code').val() is ''
      $('#user_seed_code').val('theta')
    return true
  )