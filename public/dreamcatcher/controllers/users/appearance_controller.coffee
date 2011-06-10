$.Controller 'Dreamcatcher.Controllers.Users.Appearance',

  model: {
    image: Dreamcatcher.Models.Image
    entry: Dreamcatcher.Models.Entry
    user: Dreamcatcher.Models.User
  } 
  
  data: {
    entryId: ->
      return $('#showEntry .entry:visible:first').data 'id'
    isNewEntry: ->
      return $("#new_entry").exists() and $('#new_entry').is ':visible'
  } 
    
  init: ->
    @defaultCategory = $('#defaultGenre').val() #todo: update dom to category

  showPanel: ->
    $('#appearancePanel').show()
    if not @bedsheets?
      @bedsheets = new Dreamcatcher.Controllers.Users.Bedsheets $('#bedsheetScroller')
      @bedsheets.load @defaultCategory
      $('#genreSelector').append "<option>#{category}</option>" for category in @model.image.types[0].categories
      $('#genreSelector').val @defaultCategory if @defaultCategory?
      

  'appearance.update subscribe': (called, data) ->
    #todo: consistency bedsheet_id, bedsheet_attachement should be image_id & scrolling.
    newData = {}
    newData['image_id'] = data.bedsheet_id if data.bedsheet_id?
    newData['bedsheet_attachment'] = data.scrolling if data.scrolling?
    newData['theme'] = data.theme if data.theme?
    
    if @data.isNewEntry()
      $("#entry_view_preference_attributes_image_id").val(data.bedsheet_id) if data.bedsheet_id?
      $("#entry_view_preference_attributes_bedsheet_attachment").val(data.scrolling) if data.scrolling?
      $("#entry_view_preference_attributes_theme").val(data.theme) if data.theme?
    else
      entryId = @data.entryId()
      if entryId?
        @model.entry.setViewPreferences entryId, data
        el = $('#showEntry .entry:visible:first')
      else
        @model.user.setViewPreferences data
        el = $('#userInfo')
        
      existingData = el.data 'viewpreference'
      $.extend existingData, newData
      el.data 'viewpreference', existingData
    
    @publish 'appearance.change', newData


  '#scroll,#fixed click': (el) ->    
    scrolling = el.attr 'id'
    $('#body').removeClass('fixed scroll').addClass scrolling
    @publish 'appearance.update', {scrolling: scrolling}
    
  '#light,#dark click': (el) ->
    theme = el.attr 'id'
    $('#body').removeClass('light dark').addClass theme
    @publish 'appearance.update', {theme: theme}
      
  '#genreSelector change': (el) ->
    @bedsheets.load el.val()