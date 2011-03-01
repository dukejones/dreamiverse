# THESE ARE NOT WORKING

window.injectCss = (src) ->
  headID = document.getElementsByTagName("head")[0];         
  cssNode = document.createElement('link');
  cssNode.type = 'text/css';
  cssNode.rel = 'stylesheet';
  cssNode.href = src;
  cssNode.media = 'screen';
  $('head').append(cssNode);


window.injectJs = (src) ->
  headID = document.getElementsByTagName("head")[0];         
  newScript = document.createElement('script');
  newScript.type = 'text/javascript';
  newScript.src = src;
  $('head').prepend(newScript);