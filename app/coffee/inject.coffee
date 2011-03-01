# THESE ARE NOT WORKING
window.injectJs = (src) ->
  $.getScript(src, ->
    alert('Load was performed.');
  );
  #document.write("<script src='" + src + "'><\/script>");