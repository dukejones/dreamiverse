$.Controller 'Dreamcatcher.Controllers.Users.AppearancePanel', {
  pluginName: 'appearancePanel'
}, {

  model: {
    image: Dreamcatcher.Models.Image
    entry: Entry
    user: Dreamcatcher.Models.User
  }
  data: {
    entryId: ->
      return $('#showEntry .entry:visible:first').data 'id'
    isNewEntry: ->
      return $("#new_entry").exists() and $('#new_entry').is ':visible'
  }
  getView: (name, args) ->
    return $.View "/dreamcatcher/views/bedsheets/#{name}.ejs", args
    
  init: ->
    @defaultCategory = $('#defaultGenre').val() #todo: update dom to category
    $('#genreSelector').append "<option>#{category}</option>" for category in @model.image.types[0].categories
    $('#genreSelector').val @defaultCategory if @defaultCategory?

  showPanel: ->
    $('#appearancePanel').show()
    @loadBedsheets @defaultCategirt

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
    @loadBedsheets el.val()
    
  loadBedsheets: (category) ->
    $("#bedsheetScroller .spinner").show()
    Dreamcatcher.Models.Image.search { ids_only: true, section: 'bedsheets', category: category }, @callback('populate')

  populate: (bedsheets) ->
    $("#bedsheetScroller ul").html @getView 'list', { bedsheets: bedsheets }
    $("#bedsheetScroller ul").show()
    $("#bedsheetScroller .spinner").hide()

  '.bedsheet click': (el) ->
    bedsheetId = el.data 'id'
    el.prepend '<div class="spinner"></div>'
    $(".bedsheet").removeClass 'selected'
    el.addClass 'selected'
    @publish 'appearance.update', { bedsheet_id: bedsheetId }
    
}