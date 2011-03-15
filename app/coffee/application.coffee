window.log = (msg)-> console.log(msg) if console?

# detect a clients utc offset time in minutes and write it to a cookie for the 
# application_controller set_client_timezone method
if !$.cookie('timezone') 
  current_time = new Date()
  alert('setting time zone: '+ current_time.getTimezoneOffset())
  $.cookie('timezone', current_time.getTimezoneOffset(), { path: '/', expires: 10 } )
