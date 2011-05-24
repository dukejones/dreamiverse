## STATE MANAGEMENT
###
saveState: () ->
  state = {
    section: @section
    type: @type
    category: @category
    artist: @artist
    searchOptions: @searchOptions
    currentView: @currentView
    manageShow: @manageShow
    
    dropbox: $("#dropbox").offset()
  }
  @stateCookie.set JSON.stringify(state)

restoreState: ->
  state = JSON.parse @stateCookie.get()
  if state?    
    @section = state.section
    @type = state.type
    @category = state.category
    @artist = state.artist
    
    @showArtistList() if @category?
    @showAlbumList() if @artist?
    
    $("#dropbox").offset state.dropbox if state.dropbox
    
    @displayScreen state.currentView, null
###