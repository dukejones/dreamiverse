sharingController = null

$(document).ready ->
  sharingController = new SharingController('.sharing')



class SharingController
  constructor: (containerSelector)->
    @$container = $(containerSelector)
    @$dropdown = @$container.find('.dropdown')
    
    @sharingView = new SharingView(containerSelector)
    @shareSettings = new Share()
    
    @$dropdown.change( (event) =>
      @sharingView.changeView($(event.currentTarget).val())
      @shareSettings = new Share($(event.currentTarget).val())
    )


class SharingView
  constructor: (containerSelector, type = 'everyone')->
    @$container = $(containerSelector)
    @changeView(type)
  
  changeView: (type) ->
    @type = type
    
    # logic to update the visual display
    switch @type
      when "everyone"
        $.publish 'share:change', [''] # these publish calls are not used any longer
      when "list"
        $.publish 'share:change', ['list'] # the view change will go here
      when "anonymous"
        $.publish 'share:change', ['anonymous'] # this is just holding
      when "private"
        $.publish 'share:change', ['private'] # the space for UI changes

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