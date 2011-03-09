window.contextController = null

$(document).ready ->
  window.contextController = new ContextController('#contextPanel')

class ContextController
  constructor: (containerSelector) ->
    @$container = $(containerSelector + ' .profile')
    
    @contextView = new ContextView(containerSelector)
    
    currentLocation = document.URL
    locationArray = currentLocation.split('/')
    currentFilter = locationArray[locationArray.length - 1]
    @contextView.displayFilterState(currentFilter)
    
    @$container.find('.change').click (event) =>
      @contextView.showEditProfile()
    
    @$container.find('.cancel').click (event) =>
      @contextView.showProfile()
    
    $(containerSelector).find('.context').click (event) =>
      @toggleProfile()
    
    # why isnt this working?
    $.subscribe 'profile:expand', (data)=>
      @toggleProfile()
    
    $('form#update_profile').bind 'ajax:beforeSend', (xhr, settings)=>
      @contextView.showProfile()
      
      # Is this the best way to do this? Or should we use data coming back?
      $profileDetails = $('.profile .details')
      $profileDetails.find('.website').text($('#user_link').val())
      $profileDetails.find('.email').text($('#user_email').val())
      $profileDetails.find('.phone').text($('#user_phone').val())
      $profileDetails.find('.skype span').text($('#user_skype').val())
      $('.profile .view .name').text($('#user_name').val())
    
    $('form#update_profile').bind 'ajax:success', (data, xhr, status)->
      $('p.notice').text('Profile has been updated')
    
    $('form#update_profile').bind 'ajax:error', (xhr, status, error)->
      $('p.alert').text(error)
  toggleProfile:  ->
    if @contextView.profileState() is 'none'
      @contextView.expandProfile()
    else
      @contextView.contractProfile()

class ContextView
  constructor: (containerSelector) ->
    @$container = $(containerSelector  + ' .profile')
    @$viewPanel = @$container.find('.view')
    @$editPanel = @$container.find('.edit')
    @$namePanel = @$container.find('.name')
    @$detailsPanel = @$container.find('.details')
  displayFilterState: (filter_state) ->
    # Change the current filter state to whatever is passed
    switch filter_state
      when 'visions', 'experiences', 'articles'
        $('.entryFilter.entries').find('.value').text(filter_state)
        $('.entryFilter.entries').find('.label').addClass('selected')
      when 'friends', 'following', 'followers'
        $('.entryFilter.friends').find('.value').text(filter_state)
        $('.entryFilter.friends').find('.label').addClass('selected')
  profileState: ->
    @$namePanel.css('display')
  showEditProfile: ->
    @$viewPanel.hide()
    @$editPanel.show()
  showProfile: ->
    @$viewPanel.show()
    @$editPanel.hide()
  expandProfile: ->
    @$namePanel.slideDown(250)
    @$detailsPanel.slideDown(250)
  contractProfile: ->
    @$namePanel.slideUp(250)
    @$detailsPanel.slideUp(250)