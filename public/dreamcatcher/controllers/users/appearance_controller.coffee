$.Controller 'Dreamcatcher.Controllers.Users.Appearance',

  model: {
    image: Dreamcatcher.Models.Image
    appearance: Dreamcatcher.Models.Appearance
  } 

  init: ->
    @newEntry = $("#entry_view_preference_attributes_theme").exists()
    @entryId = $('#showEntry').data 'id' if $('#showEntry').exists()
    @defaultCategory = $('#defaultGenre').val() #todo: update dom to category

  showPanel: ->
    $('#appearancePanel').show()
    if not @bedsheets?
      @bedsheets = new Dreamcatcher.Controllers.Users.Bedsheets $('#bedsheetScroller')
      @bedsheets.load @defaultCategory
      $('#genreSelector').append "<option>#{category}</option>" for category in @model.image.types[0].categories
      $('#genreSelector').val @defaultCategory if @defaultCategory?
      

  'appearance.update subscribe': (data) ->
    if @newEntry
      $("#entry_view_preference_attributes_image_id").val(data.bedsheet_id) if data.bedsheet_id?
      $("#entry_view_preference_attributes_bedsheet_attachment").val(data.scrolling) if data.scrolling?
      $("#entry_view_preference_attributes_theme").val(data.theme) if data.theme?
    else
      @model.appearance.update @entryId, data

  '#scroll,#fixed click': (el) ->    
    scrolling = el.attr 'id'
    $('#body').removeClass('fixed scroll').addClass scrolling
    @publish 'appearance.update', {scrolling: scrolling}
    
  '#light,#dark click': (el) ->
    theme = el.attr 'id'
    $('#body').removeClass('light dark').addClass theme
    @publish 'appearance.update', {scrolling: scrolling}
      
  '#genreSelector change': (el) ->
    @bedsheets.load el.val()