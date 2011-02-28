window.injectCss = (src) ->
  headID = document.getElementsByTagName("head")[0];         
  cssNode = document.createElement('link');
  cssNode.type = 'text/css';
  cssNode.rel = 'stylesheet';
  cssNode.href = src;
  cssNode.media = 'screen';
  headID.appendChild(cssNode);

window.injectJs = (src) ->
  headID = document.getElementsByTagName("head")[0];         
  newScript = document.createElement('script');
  newScript.type = 'text/javascript';
  newScript.src = src;
  headID.appendChild(newScript);