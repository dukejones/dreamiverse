window.IB ||= {}

class window.ImageBank
  constructor: ->
    new Nav()

class Nav
  constructor: ->
    config =
      over: ->
        $(this).find('.nav-expand').fadeIn()
      sensitivity: 20 
      interval: 30
      out: ->
        $(this).find('.nav-expand').fadeOut()

    $('#IB_browse li').hoverIntent(config)
    $('#IB_browse li').find('.nav-expand p').unbind()
    $('#IB_browse li').find('.nav-expand p').click( ->
      loadArtistList($(this).text())
    )
    $('#IB_browse li').find('span').unbind()
    $('#IB_browse li').find('span').click(->
      loadCategoryList($(this).text())
    )
    

