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
        iconFileSource = 'private-24-hover.png'
      when "50"
        iconFileSource = 'anon-24-hover.png'
      when "150"
        iconFileSource = 'friend-24-follower.png'
      when "200"
        iconFileSource = 'friend-24.png'
      when "500"
        iconFileSource = 'sharing-24-hover.png'

    iconSource = 'asset-url("icons/' + iconFileSource + '") no-repeat center'
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
    $('#bodyClick').hide()

  expandCurrentView: (type) ->
    @isExpanded = true
    @type = type

    # Hide all items
    @$container.find('.target').hide()

    # Remove any bodyclick & create a new one
    $('#bodyClick').show()

    #$('html, body').animate({scrollTop:0}, 'slow');

    $('#bodyClick').click( (event) =>
      @$container.find('.target').hide()
      $('#bodyClick').hide()
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
