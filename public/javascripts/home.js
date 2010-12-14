$dc = {};
$(document).ready(function(){
  $dc.action = (function() {
    var showMessages = function(serverData) {
      var messages = serverData.messages;
      var title = $('#messageTitle');
      if (serverData.type === 'success') {
        title.removeClass('error').addClass('success').html('success');
      } else {
        title.removeClass('success').addClass('error').html('error...');
      }

      $('#messageBox').show();
      // convert to unordered list items, and append.
      var ul = $('.message-content ul');
      $(messages).each(function(i, message) {
        msgLi = $("<li>", {text: message});
        ul.append(msgLi);
      });
    }
    return {
      showMessages: showMessages
    }
  })();

  $dc.signup = (function() {
    var signupButton = $('#signupButton');
    var signupButtonBack = $('#signupBack');
    var signupForm = $('#signup');
  
    signupButtonBack.css('width', '0px');
  
    signupForm.hide();
    signupButtonBack.hide();
  
    signupButtonBack.click(function() { contract() });
    signupButton.click(function() { expand() });
  
    // Hover event for next buttons
    $('.signup-next').hover(function(){
      $(this).addClass('selected');
      $(this).css('height', ($(this).css('height') - 4));
    }, function(){
      $(this).removeClass('selected');
      $(this).css('height', ($(this).css('height') + 4));
    });

    // Hover event for back arrows
    signupButtonBack.hover(function(){
      $(this).addClass('selected');
      $(this).css('height', ($(this).css('height') - 4));
    }, function(){
      $(this).removeClass('selected');
      $(this).css('height', ($(this).css('height') + 4));
    });
  
    // Setup signup button rollover to show fb login
    var fbHover = $('#fbHover');
    fbHover.hide();
    signupButton.hover(function(){
      fbHover.fadeIn();
      $(this).addClass('selected');
    }, function(){
      fbHover.fadeOut();
      $(this).removeClass('selected');
    });

    fbHover.find('.fb_button_text').html('with facebook');
  
    var contract = function() {
      signupButtonBack.animate({width: 0}, 200, 'linear', function(){
        $(this).hide();
      });
      signupButton.delay(75).animate({width: 434}, 400, 'linear');
    
      signupForm.slideUp();
    
      $('#dreamSphereButton, #shareButton').slideDown();
    
      signupButton.removeClass('selected');
    
      // Hover for button
      var fbHover = $('#fbHover');
      fbHover.hide();
      signupButton.hover(function(){
        fbHover.fadeIn();
        $(this).addClass('selected');
      }, function(){
        fbHover.fadeOut();
        $(this).removeClass('selected');
      });
    };
    var expand = function() {
      if (signupForm.css('display') != 'none') { return false; }

      // Change background height
      //$('actionButtons').animate({height: 460}, 300, 'linear');
  
      signupButton.animate({width: 360}, 200, 'linear', function(){
        signupButtonBack.show().animate({ width: 44 }, 400, 'linear', function(){ $('#fbHover').hide() });
      });
    
      $('#dreamSphereButton, #shareButton, #sharePanel').slideUp();
      $('#signup').slideDown();
    
      var fbHover = $('#fbHover');
      fbHover.hide().delay(1000).hide();
      $('#signupButton').unbind('mouseenter').unbind('mouseleave');
    
      signupButton.addClass('selected');
    };
  
    return {
      contract : contract,
      expand   : expand
    }
  
  })();
  
  $dc.share = (function() {
    var shareButton = $('#shareButton');
    var shareButtonBack = $('#shareBack');
    var sharePanel = $('#sharePanel');

    shareButtonBack.css('width', '0px');
    shareButtonBack.hide();
    sharePanel.hide();

    shareButtonBack.hover(function(){
      $(this).addClass('selected');
      $(this).css('height', ($(this).css('height') - 4));
    }, function(){
      $(this).removeClass('selected');
      $(this).css('height', ($(this).css('height') + 4));
    });

    shareButtonBack.click(function() { contract() });
    shareButton.click(function() { expand() });

    // Hover for select state
    shareButton.hover(function(){
      $(this).addClass('selected');
    }, function(){
      $(this).removeClass('selected');
    });

    var contract = function() {
      shareButtonBack.animate(
        {width: 0}, 200, 'linear', function(){
          $(this).hide();
        }
      );

      shareButton.delay(60).animate({width: 434}, 400, 'linear');
      sharePanel.slideUp();

      $('#dreamSphereButton, #signupButton').slideDown();

      shareButton.removeClass('selected');

      // Hover for select state
      shareButton.hover(function(){
        $(this).addClass('selected');
      }, function(){
        $(this).removeClass('selected');
      });
    };

    var expand = function() {
      if (sharePanel.css('display') != 'none') { return false; }

      shareButton.animate({width: 360}, 200, 'linear', function(){
        shareButtonBack.show().animate({width: 44}, 400, 'linear');
      });

      sharePanel.slideDown();
      $('#dreamSphereButton, #signupButton, #signupPanel').slideUp();
      $('#shareButton').unbind('mouseenter').unbind('mouseleave');

      shareButton.addClass('selected');
    };

    return {
      expand  : expand,
      contract: contract
    };
  })();

  $dc.fbSignin = (function(){
    var fbSignin = $('#fbSignin');
    var fbSigninBackButton = $('#fbSigninBack');
    var fbJoinButton = $('#fbJoin');
    
    fbSignin.hide();
  
    fbSigninBackButton.hover(function(){
      $(this).addClass('selected');
      $(this).css('height', ($(this).css('height') - 4));
    }, function(){
      $(this).removeClass('selected');
      $(this).css('height', ($(this).css('height') + 4));
    }).click(function() { contract(); });
    
    fbJoinButton.click(function(){
      showSignupForm();
    })

    var expand = function() {
      $('#dreamSphereButton, #signupButton, #shareButton, #signup, #sharePanel').slideUp();
      $('#fbSignInLabel').hide();
      fbSignin.slideDown();
    };

    var contract = function() {
      $('#dreamSphereButton, #signupButton, #shareButton').slideDown();
      fbSignin.slideUp();
    };
    
    var showSignupForm = function() {
      contract();
      signup = $dc.signup;
      signup.expand();
    };
    
    return {
      expand    : expand,
      contract  : contract
    }
  })();

  $dc.infoBox = (function(){
    var showWhatIs = function() {

      if(!$(this).hasClass('selected')){
        $('#infoNav').find('a').removeClass('selected');
        $('#whatisdc').addClass('selected');
        
        $('#about-box, #contact-box').fadeOut();
        $('#about-box, #contact-box').slideUp();
        $('#info-box').fadeIn();
      }
    };
    
    var showAbout = function() {
      if(!$(this).hasClass('selected')){
        $('#infoNav').find('a').removeClass('selected');
        $('#aboutdc').addClass('selected');

        $('#contact-box, #info-box').fadeOut();
        $('#contact-box, #info-box').slideUp();
        $('#about-box').fadeIn();
      }
    };
    
    var showContact = function() {
      if(!$(this).hasClass('selected')){
        $('#infoNav').find('a').removeClass('selected');
        $('#contactdc').addClass('selected');

        $('#about-box, #info-box').fadeOut();
        $('#about-box, #info-box').slideUp();
        $('#contact-box').fadeIn();
      }
    }
    
    $('#whatisdc').click(function(){ showWhatIs() });
    $('#aboutdc').click(function(){ showAbout() });
    $('#contactdc').click(function() { showContact() });

    return {
      showWhatIs  : showWhatIs,
      showAbout   : showAbout,
      showContact : showContact
    };
  })();

  $dc.forgotPass = (function(){
    $('#forgotPass').hide();
    $('#forgotPassLink').click(function(){ expand() });
    $('#forgotPassBack').click(function(){ contract() });

    var expand = function() {
      $('#sharePanel, #signup, #fbSignin').slideUp();
      $('#signupButton, #shareButton, #dreamSphereButton, #fbSignin').slideUp();
      $('#forgotPass').slideDown();
    };

    var contract = function() {
      // $('#loginBox').show();
      $('#forgotPass').slideUp();    
      $('#signupButton, #shareButton, #dreamSphereButton').slideDown();
    };

    return {
      expand  : expand,
      contract: contract
    }
  })();


  $('#emailField').focus();

  $('.terms-link').click(function() {
    window.open(
      this.href, 
      "Terms of Service", 
      'width=768, height=768, toolbar=no, location=no, directories=no, menubar=no, scrollbars=yes'
    );
    return false;
  });


  $dc.buttons = [$dc.signup, $dc.share, $dc.fbSignin, $dc.infoBox, $dc.forgotPass];

  
  // Apply extra functionality to <fb:login-button> in the login box.
  $('#loginBox [perms]').click(function() {
    FB.getLoginStatus(function(response) {
      if (response.session) { window.location = '/login'; }
    });
  }).one('click', function() {
    FB.Event.subscribe('auth.sessionChange', function(response) { 
      window.location = '/login'; 
    });
  });
  
  // Apply extra functionality to <fb:login-button> in the SIGNUP form
  $('#fbHover [perms]').one('click', function() {
    FB.Event.subscribe('auth.statusChange', function(response) {
      FB.api('/me', function(data) {
        // Set email & username
        $('#signupUsername').val(data.first_name);
        $('#signupEmail').val(data.email)
      });
      
      
    });
  });
  
});
