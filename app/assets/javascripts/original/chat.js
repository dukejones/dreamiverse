$(document).ready(function(){
  initChatElements();
})

function initChatElements(){
  $('.tagChat .chat input').focus(function(){
    if($(this).val() == 'comment'){
      $(this).val('');
    }
  })
  $('.tagChat .chat input').blur(function(){
    if($(this).val() == ''){
      $(this).val('comment');
    }
  })
  
  $('.tagChat .chat .input .submit').click(function(){
    if($(this).prev().val() != ''){
      // Put chat in
      var newChat = '<div class="userComment hidden"><img src="/images/avatars/xavitar.jpg" class="avatar"><div class="name">' + 'USER' + '</div><div class="comment">' + $(this).prev().val() + '</div></div>'
      $(this).parent().before(newChat);
      $('.userComment').slideDown(250);
      $(this).prev().val('');
    }
  })
  
  // Submit on enter
  $(".tagChat .chat .input").keyup(function(e) {
    if(e.keyCode == 13) {
      // Put chat in
      var newChat = '<div class="userComment hidden"><img src="/images/avatars/xavitar.jpg" class="avatar"><div class="name">' + 'USER' + '</div><div class="comment">' + $(this).find('input').val() + '</div></div>'
      $(this).before(newChat);
      $('.userComment').slideDown(250);
      $(this).find('input').val('');
    }
  });
}