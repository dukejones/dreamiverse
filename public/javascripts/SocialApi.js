// SocialApi is a pseudo-object which acts as a container for static functions which manipulate
// the aspects of the Social Network via calls to the server.

SocialApi = {
  linkFacebookAccount: function(fbResponse) {
    $.post(
      '/facebook/associate-user',
      { fb_uid: fbResponse.session.uid },
      function(data) {
        // success callback.
        // Display fb account info & set data
      }
    );
  }
}
