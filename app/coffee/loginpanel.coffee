# Login Panel
$(document).ready ->
  # Checks if .loginPanelWrap exits
  # runs specific code for it, otherwise
  # starts the loginController for the rest
  # of the pages
  
  if $('.loginPanelWrap').attr('class')
    $('.loginPanelWrap a.login').unbind()
    $('.loginPanelWrap a.login').click (event) ->
      event.preventDefault()
      
      if $(this).parent().find('.loginPanel').css('display') == 'none'
        $(this).parent().find('.loginPanel').slideDown('400', (event) ->
          $('#user_username').focus()
        )
        
        
        bodyClick = '<div id="bodyClick" style="z-index: 1100; cursor: pointer; width: 100%; height: 100%; position: fixed; top: 0; left: 0;" class=""></div>'
        $('body').prepend(bodyClick)
  
        $('#bodyClick').click( (event) =>
          $('.loginPanel').slideUp()
          $('#bodyClick').remove()
        )
      else
        $(this).parent().find('.loginPanel').slideUp()
    
    # Check for cookie "welcome" if found, do nothing
    # if not found, display the welcomeWrap
    #if window.getCookie("welcome") is null
    $('.welcomeWrap').slideDown()
    # Setup cookies for thank you button
    $('.thankyou').click ->
      # fade out welcome
      $(this).parent().parent().slideUp()
      # set cookie
      #window.setCookie("welcome", 1, 365)
    
    #window.deleteCookie("welcome") #use this to debug (remove your cookie)
      
  else
    login = new LoginController('.rightPanel')

class window.LoginController
  # Handles the logic & interactions
  constructor: (containerSelector)->
    @$container = $(containerSelector) #may not need to store this?
    
    @loginView = new LoginView(containerSelector)
  

class LoginModel
  # Data Model for logging in


class LoginView
  # Handles the visual display of the
  # login panel
  constructor: (containerSelector)->
    @$container = $(containerSelector)
    @$loginButton = @$container.find('.login')

    @$loginPanel = @$container.find('.loginPanel') #submits
    
    @$loginButton.unbind()
    @$loginButton.click => @showLogin()
    
    @bodyClickVisible = false
    
    $('.haveSeedcode').click =>
      $('.haveSeedcode').slideUp('fast')
      $('.seedcodeExpander').slideDown('fast')
  
  closePanel: ->
    @bodyClickVisible = false
    @$loginButton.show()
    
    @$loginPanel.slideUp()
  
  showLogin: ->
    if !@bodyClickVisible
      @bodyClickVisible = true
      @displayBodyClick()
      @$loginPanel.slideDown()
    else
      @$loginPanel.show()  
  
    @$loginButton.hide()
    
  displayBodyClick: ->
    @bodyClickVisible = true
    $('#bodyClick').remove()
    bodyClick = '<div id="bodyClick" style="z-index: 1100; cursor: pointer; width: 100%; height: 100%; position: fixed; top: 0; left: 0;" class=""></div>'
    $('body').prepend(bodyClick)
  
    #$('html, body').animate({scrollTop:0}, 'slow');
  
    $('#bodyClick').click( (event) =>
      @bodyClickVisible = false
      @closePanel()
      $('#bodyClick').remove()
    )
    
  