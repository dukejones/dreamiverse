# Login Panel
$(document).ready ->
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
    @$joinButton = @$container.find('.joinWrap')
    @$signupButton = @$container.find('.signupWrap')
    
    @$signupPanel = @$container.find('.signupPanel') #expands
    @$loginPanel = @$container.find('.loginPanel') #submits
    
    @$loginButton.click => @showLogin()
    @$joinButton.click => @showSignup()
    $('.haveSeedcode').click => $('#user_seed_code').show()
  
  closePanel: ->
    @bodyClickVisible = false
    @$signupButton.hide()
    @$joinButton.show()
    @$loginButton.show()
    
    @$loginPanel.slideUp()
    @$signupPanel.slideUp()
  
  showLogin: ->
    if !@bodyClickVisible
      @bodyClickVisible = true
      @displayBodyClick()
      @$loginPanel.slideDown()
    else
      @$loginPanel.show()
      
    @$signupPanel.hide()
    @$signupButton.hide()
    @$joinButton.show()
  
    @$loginButton.hide()
  
    @$signupButton.unbind()
    @$signupButton.click => @showSignup()
  
  showSignup: ->
    if !@bodyClickVisible
      @bodyClickVisible = true
      @displayBodyClick()
      @$signupPanel.slideDown()
    else
      @$signupPanel.show()
      
    @$loginButton.show()
    @$signupButton.show()
  
    @$joinButton.hide()
    @$loginPanel.hide()
    
  showSeedCodeInput: ->
    # hide seed code button show seed code input
  
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
    
  