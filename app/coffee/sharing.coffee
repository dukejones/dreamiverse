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
      @sharingChangeHandler(event)
    )
    
    #setup Default Sharing dropdown
    @$dropdown.val($('.sharingWrap .sharing').data('id'))
    #@$dropdown.change()
    @sharingChangeHandler() 
    @$container.find('.target').hide()
  
  sharingChangeHandler: ->
    # get the new icon path
    newSelection = @$dropdown.val()
    
    switch newSelection
      when "0"
        iconFileSource = 'private-16-select.png'
      when "50"
        iconFileSource = 'anon-16-select.png'
      when "150"
        iconFileSource = 'friend-follower-16.png'
      when "200"
        iconFileSource = 'friend-16.png'
      when "500"
        iconFileSource = 'sharing-16-select.png'
    
    iconSource = 'url(/images/icons/' + iconFileSource + ') no-repeat center'
    $('.listSelection').css('background', iconSource)
    
    if !@firstRun
      @sharingView.expandCurrentView(newSelection)
    else
      @firstRun = false
    
    @shareSettings = new Share(newSelection)


class SharingView
  constructor: (containerSelector, type = 'everyone')->
    @$container = $(containerSelector)
    @type = type
    
  contractCurrentView: ->
    @isExpanded = false
    
    @$container.find('.target').slideUp(250)
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
        @$container.find('.everyone').slideDown(250)
      when "list"
        @$container.find('.listOfUsers').slideDown(250)

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