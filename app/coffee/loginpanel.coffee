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
  
  showLogin: ->
    @$signupPanel.hide()
    @$signupButton.hide()
    @$joinButton.show()
    
    @$loginButton.hide()
    @$loginPanel.show()
    
    @$signupButton.unbind()
    @$signupButton.click => @showSignup()
  
  showSignup: ->
    @$loginButton.show()
    @$signupButton.show()
    
    @$joinButton.hide()
    @$loginPanel.hide()
    
    @$signupPanel.slideDown()
    
  showSeedCodeInput: ->
    # hide seed code button show seed code input
    
  