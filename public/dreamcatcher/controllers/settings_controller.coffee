$.Controller 'Dreamcatcher.Controllers.Settings',

  init: ->
    @setupDefaults()
    @setupAjaxBinding()
    
  setupDefaults: ->
    defaultSharingLevel = $('#default-sharing').data 'id'
    defaultLandingPage = $('#default-landingPage').data 'id'
    defaultMenuStyle = $('#default-menuStyle').data 'id'
    log('fms: '+ defaultMenuStyle)
    $('#default-sharing-list').val(defaultSharingLevel)
    $('#default-landingPage-list').val(defaultLandingPage)
    $('#default-menuStyle-list').val(defaultMenuStyle)
    
    @displayDefaultSharingLevel defaultSharingLevel
    @displayDefaultLandingPage defaultLandingPage
    @displayDefaultMenuStyle defaultMenuStyle
 
    
  showPanel: ->    
    $('#settingsPanel').show()

  displayDefaultSharingLevel: (defaultSharingLevel) ->
    # TODO: after SASS refactor, replace with class
    defaultSharingLevel = parseInt defaultSharingLevel
    switch defaultSharingLevel
      when 500 then background = 'sharing-24-hover.png'
      when 200 then background = 'friend-24.png'
      when 150 then background = 'friend-24-follower.png'
      when 50 then background = 'anon-24-hover.png'
      when 0 then background = 'private-24-hover.png'

    $('.sharing-icon').css "background","url(/images/icons/#{background}) no-repeat center transparent"

  displayDefaultLandingPage: (defaultLandingPage) ->
    # TODO: after SASS refactor, replace with class
    switch defaultLandingPage
      when 'stream' then background = 'stream-24-hover.png'
      when 'home' then background = 'home-24-hover.png'
      when 'today' then background = 'home-24-hover.png'
    
    $('.landing-icon').css "background","url(/images/icons/#{background}) no-repeat center transparent"

  displayDefaultMenuStyle: (defaultMenuStyle) ->
    # TODO: after SASS refactor, replace with class
    switch defaultMenuStyle
      when 'stream' then background = 'stream-24-hover.png'
      when 'home' then background = 'home-24-hover.png'
      when 'today' then background = 'home-24-hover.png'

    $('.landing-icon').css "background","url(/images/icons/#{background}) no-repeat center transparent"
    
    
  updateSettingsModel: (params) ->
    Dreamcatcher.Models.Settings.update params


  setupAjaxBinding: ->
    #TODO: Needs refactoring.
    $('#fbLink').bind 'ajax:success', (event, xhr, status)->
      $('#fbLink').remove()
      $('.network').append '<a id="fbLink" href="/auth/facebook" class="linkAccount">link account</a>'

    $('form#change_password').bind 'ajax:beforeSend', (xhr, settings)->
      $('.changePassword .target').hide()

    $('form#change_password').bind 'ajax:success', (data, xhr, status)->
      $('p.notice').text xhr.message
      if xhr.errors
        for error, message of xhr.errors
          $('#user_' + error).prev().text message[0]
        $('.changePassword .target').slideDown 250
      else
        $('#change_password .error').text ''
        $('#user_old_password, #user_password, #user_password_confirmation').val ''

    $('form#change_password').bind 'ajax:error', (xhr, status, error)->
      log xhr.errors
    
    
  '#default-sharing-list change': (element) ->
    defaultSharingLevel = element.val()
    @displayDefaultSharingLevel defaultSharingLevel
    @updateSettingsModel {'user[default_sharing_level]': parseInt defaultSharingLevel}

  '#default-landingPage-list change': (element) ->
    defaultLandingPage = element.val()
    @displayDefaultLandingPage defaultLandingPage
    @updateSettingsModel {'user[default_landing_page]': defaultLandingPage} 

  '#default-menuStyle-list change': (element) ->
    defaultMenuStyle = element.val()
    @displayDefaultMenuStyle defaultMenuStyle
    @updateSettingsModel {'user[default_menu_style]': defaultMenuStyle} 

  '.cancel click': ->
    $('.changePasswordForm').hide()
    $('#user_password,#user_password_confirmation').val ''
