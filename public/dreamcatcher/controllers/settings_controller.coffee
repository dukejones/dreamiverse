$.Controller 'Dreamcatcher.Controllers.Settings',

  init: ->
    @firstRun = true
    
  load: ->
    #setup default sharing 
    @defaultSharingId = $('#settingsPanel .defaultSharing').data('id') 
    $('#sharingList').select(@defaultSharingId)
    $('#sharingList').change()
    
    #refactor following code into proper methods...see below
    $('form#change_password').bind 'ajax:beforeSend', (xhr, settings) ->
      $('.changePassword .target').hide()
      
    $('form#change_password').bind 'ajax:success', (data, xhr, status)->
      $('p.notice').text(xhr.message)
      if xhr.errors
        for error, message of xhr.errors
          $('#user_' + error).prev().text(message[0])
        # open the panel back up
        $('.changePassword .target').slideDown(250)
      else
        $('#change_password .error').text('')
        $('#user_old_password, #user_password, #user_password_confirmation').val('')

  show: ->    
    $('#settingsPanel').show()

  # setup default sharing dropdown change
  '#sharingList change': (el, ev) ->
    value = el.find('option:selected')[0].value

    switch value
      when "500" then background = 'sharing-24-hover.png'
      when "200" then background = 'friend-24.png'
      when "150" then background = 'friend-follower-24.png'
      when "50" then background = 'anon-24-hover.png'
      when "0" then background = 'private-24-hover.png'

    $('.sharingIcon').css("background", "url(/images/icons/#{background}) no-repeat center transparent")

    #only update if first run?
    @update(value) if !@firstRun
    @firstRun = false

  update: (sharingLevel) ->
    Dreamcatcher.Models.Settings.update(sharingLevel)

  
  #? - next 4, not sure if ajax: works in this model... find a good way!
  '#fbLink ajax:success': ->
    $('#fbLink').remove()
    $('.network').append('<a id="fbLink" href="/auth/facebook" class="linkAccount">link account</a>')

  'form#change_password ajax:beforeSend': (xhr, settings) ->
    alert 'before send'
  
  'form#change_password ajax:success': (data, xhr, status) ->
    alert 'success'
    
  'form#change_password ajax:error': (xhr, status, error) ->
    alert 'error'
    
  '.cancel click': ->
    $('.changePasswordForm').hide()
    $('#user_password,#user_password_confirmation').val('')


