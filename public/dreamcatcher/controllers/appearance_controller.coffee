$.Controller 'Dreamcatcher.Controllers.Appearance',

  ibModel: Dreamcatcher.Models.ImageBank

  init: ->
    @newEntry = $("#entry_view_preference_attributes_theme").exists()
    @entryId = $('#showEntry').data 'id' if $('#showEntry').exists()
    @defaultGenre = $('#defaultGenre').val()

  showPanel: ->
    $('#appearancePanel').show()
    if not @bedsheets?
      @bedsheets = new Dreamcatcher.Controllers.Bedsheets $('#bedsheetScroller'),{parent: this}
      @bedsheets.loadGenre @defaultGenre
      $('#genreSelector').append "<option>#{category}</option>" for category in @ibModel.types[0].categories
      $('#genreSelector').val @defaultGenre if @defaultGenre?
      

  updateAppearanceModel: (data) ->
    if @newEntry
      $("#entry_view_preference_attributes_image_id").val(data.bedsheet_id) if data.bedsheet_id?
      $("#entry_view_preference_attributes_bedsheet_attachment").val(data.scrolling) if data.scrolling?
      $("#entry_view_preference_attributes_theme").val(data.theme) if data.theme?
    else
      Dreamcatcher.Models.Appearance.update @entryId,data

  '#scroll,#fixed click': (el) ->    
    scrolling = el.attr 'id'
    $('#body').removeClass('fixed scroll').addClass scrolling
    @updateAppearanceModel {scrolling: scrolling}
    
  '#light,#dark click': (el) ->
    theme = el.attr 'id'
    $('#body').removeClass('light dark').addClass theme
    @updateAppearanceModel {theme: theme}
    
  '#genreSelector change': (el) ->
    @bedsheets.loadGenre el.val()