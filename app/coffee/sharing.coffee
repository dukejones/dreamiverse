sharingController = null

$(document).ready ->
  sharingController = new SharingController('.sharing')



class SharingController
  constructor: (containerSelector)->
    @$container = $(containerSelector)
    @$dropdown = @$container.find('select')
    
    @sharingView = new SharingView(containerSelector)
    @shareSettings = new Share()
    
    @$dropdown.change( (event) =>
      newSelection = @$dropdown.find('option:selected').text()
      @sharingView.changeView(newSelection)
      @shareSettings = new Share(newSelection)
    )


class SharingView
  constructor: (containerSelector, type = 'everyone')->
    @$container = $(containerSelector)
    @type = type
  
  changeView: (type) ->
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
      when "EveryoneEveryone"
        @$container.find('.everyone').slideDown()
      when "EveryoneUsers"
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