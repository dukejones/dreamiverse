window.contextController = null

$(document).ready ->
  window.contextController = new ContextController('#contextPanel')

class ContextController
  constructor: (containerSelector) ->
    @$container = $(containerSelector + ' .profile')
    
    @contextView = new ContextView(containerSelector)
    
    currentLocation = document.URL
    locationArray = currentLocation.split('=')

    # Check length of locationArray. If > 1 try looking for friends/follow filter
    if locationArray.length > 1
      currentFilter = locationArray[locationArray.length - 1]
    else
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
      $user_url = $('#user_link_attributes_url').val()
      $user_url_href = $user_url.replace(/^www./, "http://www.") # needed for www. urls
      $user_url_href = 'http://' + $user_url unless ($user_url_href.match("^http")) # needed for domain.com urls
      log('new $user_url_href: ' + $user_url_href)

      $profileDetails.find('.website .href').text($user_url) # update link text
      $profileDetails.find('.website .href').attr('href',$user_url_href) # update link url
      $profileDetails.find('.email').text($('#user_email').val())
      $profileDetails.find('.phone').text($('#user_phone').val())
      $profileDetails.find('.skype').text($('#user_skype').val())
      $('.profile .view .name').text($('#user_name').val())
    
    $('form#update_profile').bind 'ajax:success', (data, xhr, status)=>
      $('.profile .alert').find('.check').show()
      $('.profile .alert').find('.close').hide()
      
      setTimeout("$('.profile .alert').hide();", 5000)
      
      # listen for close event
      $('.profile .alert').click ->
        $('.profile .alert').unbind()
        $('.profile .alert').hide()
        
      $('.profile .alert').find('.message').html('Profile has been updated')
      $('.profile .alert').show()
      
      
    $('form#update_profile').bind 'ajax:error', (xhr, status, error)=>
      $('.profile .alert').find('.check').hide()
      $('.profile .alert').find('.close').show()
      
      setTimeout("$('.profile .alert').hide();", 5000)
      
      # listen for close event
      $('.profile .alert').click ->
        $('.profile .alert').unbind()
        $('.profile .alert').hide()
        
      $('.profile .alert').find('.message').html(error)
      $('.profile .alert').show()
      
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
    # Change the icon (Want to reduce duplication here if poss - from scott)
    switch filter_state
      when 'dreams'
        iconFileSource = 'dream-24-hover.png'
        iconSource = '/images/icons/' + iconFileSource
        $('.entryFilter.entries').find('.image').find('img').attr('src', iconSource)
      when 'visions'
        iconFileSource = 'vision-24-hover.png'
        iconSource = '/images/icons/' + iconFileSource
        $('.entryFilter.entries').find('.image').find('img').attr('src', iconSource)
      when 'experiences'
        iconFileSource = 'experience-24-hover.png'
        iconSource = '/images/icons/' + iconFileSource
        $('.entryFilter.entries').find('.image').find('img').attr('src', iconSource)
      when 'articles'
        iconFileSource = 'article-24-hover.png'
        iconSource = '/images/icons/' + iconFileSource
        $('.entryFilter.entries').find('.image').find('img').attr('src', iconSource)
      when 'friends'
        iconFileSource = 'friend-24.png'
        iconSource = '/images/icons/' + iconFileSource
        $('.entryFilter.friends').find('.image').find('img').attr('src', iconSource)
      when 'following'
        iconFileSource = 'friend-24-follow.png'
        iconSource = '/images/icons/' + iconFileSource
        $('.entryFilter.friends').find('.image').find('img').attr('src', iconSource)
      when 'followers'
        iconFileSource = 'friend-24-follower.png'
        iconSource = '/images/icons/' + iconFileSource
        $('.entryFilter.friends').find('.image').find('img').attr('src', iconSource)
      else
        iconFileSource = 'entries-24.png'
        iconSource = '/images/icons/' + iconFileSource
        $('.entryFilter.entries').find('.image').find('img').attr('src', iconSource)
      
    
    
    # Change the current filter state to whatever is passed
    switch filter_state
      when 'visions', 'experiences', 'articles', 'dreams'
        $('.entryFilter.entries').find('.value').text(filter_state)
        $('.entryFilter.entries').find('.label').addClass('selected')
      when 'friends', 'following', 'followers'
        $('.entryFilter.friends').find('.value').text(filter_state)
        $('.entryFilter.friends').find('.label').addClass('selected')
      else
        $('.entryFilter.entries').find('.value').text('entries')
        $('.entryFilter.entries').find('.label').addClass('selected')
  

  profileState: ->
    @$detailsPanel.css('display')
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