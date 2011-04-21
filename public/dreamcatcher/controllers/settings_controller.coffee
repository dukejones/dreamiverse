$.Controller 'Dreamcatcher.Controllers.Settings',

  init: ->
    @firstRun = true
    @setupDefaults()
    @setupAjaxBinding()
    
  setupDefaults: ->
    @defaultSharingId = $('#settingsPanel .defaultSharing').data('id') 
    $('#sharingList').select(@defaultSharingId)
    $('#sharingList').change()
    
  showPanel: ->    
    $('#settingsPanel').show()


  updateSharingLevel: (sharingLevel) ->
    Dreamcatcher.Models.Settings.update(sharingLevel)


  setupAjaxBinding: ->
    $('#fbLink').bind 'ajax:success', (event, xhr, status)->
      $('#fbLink').remove()
      $('.network').append('<a id="fbLink" href="/auth/facebook" class="linkAccount">link account</a>')

    $('form#change_password').bind 'ajax:beforeSend', (xhr, settings)->
      $('.changePassword .target').hide()

    $('form#change_password').bind 'ajax:success', (data, xhr, status)->
      $('p.notice').text(xhr.message)
      if xhr.errors
        for error, message of xhr.errors
          $('#user_' + error).prev().text(message[0])
        $('.changePassword .target').slideDown(250)
      else
        $('#change_password .error').text('')
        $('#user_old_password, #user_password, #user_password_confirmation').val('')

    $('form#change_password').bind 'ajax:error', (xhr, status, error)->
      log xhr.errors
    
    
  '#sharingList change': (el, ev) ->
    sharingLevel = el.val()

    #TODO: replace with class
    switch sharingLevel
      when "500" then background = 'sharing-24-hover.png'
      when "200" then background = 'friend-24.png'
      when "150" then background = 'friend-follower-24.png'
      when "50" then background = 'anon-24-hover.png'
      when "0" then background = 'private-24-hover.png'

    $('.sharingIcon').css("background", "url(/images/icons/#{background}) no-repeat center transparent")

    #only update if first run? - TODO: ask for reason why.
    @updateSharingLevel(sharingLevel) if !@firstRun
    @firstRun = false

  '.cancel click': ->
    $('.changePasswordForm').hide()
    $('#user_password,#user_password_confirmation').val('')
