sharingController = null

$(document).ready ->
  sharingController = new SharingController('.sharing')
  



class SharingController
  constructor: (containerSelector)->
    @firstRun = true;
    @$container = $(containerSelector)
    @$dropdown = @$container.find('#sharing_select')
    
    @sharingView = new SharingView(containerSelector)
    @shareSettings = new Share()
    
    @$container.find('.listSelection').click( (event) =>
      if @sharingView.isExpanded
        @sharingView.contractCurrentView()
      else
        currentSelection = @$dropdown.val()
        @sharingView.expandCurrentView(currentSelection)
    )
    
    @$dropdown.change( (event) =>
      # get the new icon path
      newSelection = @$dropdown.val()
      newSelectionImage = $(event.currentTarget).find('option:selected').css('background-image')
      newSelectionImage = newSelectionImage.slice(5, newSelectionImage.length - 2)
      
      # get the larger icon path
      largeSelectionImage = newSelectionImage.slice(0, newSelectionImage.length-6) + '24.png'
      
      $(event.currentTarget).parent().find('.listSelection').attr('src', largeSelectionImage)
      
      if !@firstRun
        @sharingView.expandCurrentView(newSelection)
      else
        @setupDefaultSharingLevel()
        @firstRun = false
      
      @shareSettings = new Share(newSelection)
    )
    
    $('.listOfUsers').find("input[type='radio']").change( (event)=>
      # get the new icon path
      newText = $(event.currentTarget).next().text()
      newIcon = $(event.currentTarget).parent().css('background-image')
      newIconPath = newIcon.slice(5, newIcon.length - 2)
      
      # get the larger icon path
      largeSelectionImage = newIconPath.slice(0, newIconPath.length-6) + '24.png'
      
      $('.listSelection').attr('src', largeSelectionImage)
      @$dropdown.find('.list').text(newText)
    )
    
    #setup Default Sharing dropdown
    if window.BrowserDetect.browser isnt "Safari" and window.BrowserDetect.browser isnt "Chrome"
      @$dropdown.val(@$container.data('id'))
      @$dropdown.change()
      
    @$container.find('.target').hide()
    
  setupDefaultSharingLevel: ->
    @$dropdown.val($('#sharingList').find('option:selected').val())


class SharingView
  constructor: (containerSelector, type = 'everyone')->
    @$container = $(containerSelector)
    @type = type
    
  contractCurrentView: ->
    @isExpanded = false
    
    @$container.find('.target').slideUp()
    $('#bodyClick').remove()
    
  expandCurrentView: (type) ->
    @isExpanded = true
    @type = type
    
    # Hide all items
    @$container.find('.target').hide()
    
    # Remove any bodyclick & create a new one
    $('#bodyClick').remove()
    bodyClick = '<div id="bodyClick" style="z-index: 1100; cursor: pointer; width: 100%; height: 100%; position: fixed; top: 0; left: 0;" class=""></div>'
    $('body').prepend(bodyClick)
  
    #$('html, body').animate({scrollTop:0}, 'slow');
  
    $('#bodyClick').click( (event) =>
      @$container.find('.target').hide()
      $('#bodyClick').remove()
    )
    
    # logic to update the visual display
    switch @type
      when "500" # Everyone
        @$container.find('.everyone').slideDown()
      when "list"
        @$container.find('.listOfUsers').slideDown()

# Sharing Model
class Share
  constructor: (type = 'everyone') ->
    @type = type
    
    # example settings object
    @settings = 
      everyone:
        facebook: false
        twitter: false
      list:
        friends: false
        followers: false
        users: [] # Array of user_id's
  
  type: -> @type
  addUser: (user_id) ->
    @settings.list.users.push user_id