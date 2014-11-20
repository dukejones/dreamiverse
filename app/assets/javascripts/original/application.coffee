window.log = (msg) -> console.log(msg) if console?

# detect a clients utc offset time in minutes and write it to a cookie for the 
# application_controller set_client_timezone method
if !$.cookie('timezone') 
  current_time = new Date()
  $.cookie('timezone', current_time.getTimezoneOffset(), { path: '/', expires: 2 } )
