$.Controller('Dreamcatcher.Controllers.Settings',

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

    @update(value) if !@firstRun 
    @firstRun = false

  update: (sharingLevel) ->
    Dreamcatcher.Models.Settings.update(sharingLevel)
)


