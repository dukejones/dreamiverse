jQuery.fn.linkify = function(){
  text = $(this).html()
  if( !text ) return text;
  
  text = text.replace(/(https?\:\/\/|ftp\:\/\/|www\.)[\w\.\-_]+(:[0-9]+)?\/?([\w#!:.?+=&(&amp;)%@!\-\/])*/gi, function(url){
    nice = url;
    if( url.match('^https?:\/\/') )
    {
      nice = nice.replace(/^https?:\/\//i,'')
    }
    else
      url = 'http://'+url;
    
    var urlTitle = nice.replace(/^www./i,'');
    return '<a target="_blank" rel="nofollow" href="'+ url +'">'+ url +'</a>';
  });
  
  $(this).html(text);
  return $(this);
}
