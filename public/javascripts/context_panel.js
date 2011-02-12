$(document).ready(function(){
  initContextMenu();
})

var friendsExpanded = false;

function initContextMenu(){

// AVATAR UPLOAD HOVER
  $('#contextPanel .avatar').bind('mouseenter', function (e) {
    $('.avatar .uploadAvatarWrap').fadeIn('fast');
  })
  .bind('mouseleave', function (e) {
    $('.avatar .uploadAvatarWrap').fadeOut();
  })

}