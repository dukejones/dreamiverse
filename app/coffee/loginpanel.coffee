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
    @$joinToggle = @$container.find('.joinToggle')
    @$joinButton = @$container.find('.joinWrap')
    @$joinButtonWrap = @$container.find('.joinButtonWrap')
    
    @$joinPanel = @$container.find('.joinPanel') #expands
    @$loginPanel = @$container.find('.loginPanel') #submits
    
    @$loginButton.unbind()
    @$loginButton.click => @showLogin()
    @$joinButton.unbind()
    @$joinButton.click => @showJoin()
    @$joinToggle.unbind()
    @$joinToggle.click => @showJoin()
    
    @bodyClickVisible = false
    
    $('.haveSeedcode').click =>
      $('.haveSeedcode').slideUp('fast')
      $('.seedcodeExpander').slideDown('fast')
  
  closePanel: ->
    @bodyClickVisible = false
    @$joinButtonWrap.hide()
    @$joinButton.show()
    @$loginButton.show()
    @$joinToggle.hide()
    
    @$loginPanel.slideUp()
    @$joinPanel.slideUp()
  
  showLogin: ->
    if !@bodyClickVisible
      @bodyClickVisible = true
      @displayBodyClick()
      @$loginPanel.slideDown()
    else
      @$loginPanel.show()
    
    @$joinPanel.hide()
    @$joinButtonWrap.hide()
    @$joinToggle.show()
    @$joinButton.hide()
    
  
    @$loginButton.hide()
  
    @$joinButtonWrap.unbind()
    @$joinButtonWrap.click => @showJoin()
  
  showJoin: ->
    if !@bodyClickVisible
      @bodyClickVisible = true
      @displayBodyClick()
      @$joinPanel.slideDown()
    else
      @$joinPanel.show()
    
    @$joinToggle.hide()
    @$loginButton.show()
    @$joinButtonWrap.show()
  
    @$joinButton.hide()
    @$loginPanel.hide()
  
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
    
  