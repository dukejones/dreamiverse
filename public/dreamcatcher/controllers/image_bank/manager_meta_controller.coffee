$.Controller 'Dreamcatcher.Controllers.ImageBank.ManagerMeta',

  ibModel: Dreamcatcher.Models.ImageBank

  init: ->
    @initLists()
  
  initLists: ->
    for type in @ibModel.types
      $("#type select").append "<option data-categories='#{JSON.stringify type.categories}'>#{type.name}</option>"
    for genre in @ibModel.genres
      $("#genre select").append "<option>#{genre}</option>"

  #- gets the type, category & genre meta (for new uploaded images)
  get: (type) ->
    if type is 'organization'
      image = {}
      $("##{type} select").each (i, el) =>
        attr = $(el).parent().attr 'id'
        value = $(el).val()
        image[attr] = if value.length > 0 then value else ''
      image.section = image.type
      #delete image.type
      return { image: image }
    # todo: other types - return when needed

  #- show only the common meta for all the selected images
  #- if only one is selected, then show all that comments meta
  update: ->
    commonMeta = {}
    $('#imagelist li.selected').each (i, el) =>
      imageMeta = $(el).data 'image' 
      #- special cases, such as date and user (i.e. needs to be converted from raw json)
      imageMeta.date = $.format.date imageMeta['created_at'].replace('T',' '), 'MMM dd, yyyy'
      imageMeta.user = 'phong'
      imageMeta.type = imageMeta.section

      for attr in @ibModel.attributes
        if not commonMeta[attr]?
          commonMeta[attr] = imageMeta[attr]
        else if commonMeta[attr] isnt imageMeta[attr]
          commonMeta[attr] = '*'
    @displayImageMeta commonMeta

  #- display's the meta data for a particular image object
  displayImageMeta: (imageMeta) ->
    for attribute in @ibModel.attributes
      @displayAttribute attribute, imageMeta[attribute] 

  #- checks if an attribute is of type "text"
  isText: (attr) ->
    return $("##{attr} input[type=text]").exists()

  #- checks if an attribute is of type "select"
  isSelect: (attr) ->
    return $("##{attr} select").exists()

  #- sets the text input or select to display a certain value
  displayAttribute: (attr, value) ->
    $("##{attr} input[type=checkbox]").attr('checked', value? and value isnt "*")
    if @isText attr
      if value is "*"
        $("##{attr} input[type=text]").val('').attr 'placeholder', 'different'
      else
        $("##{attr} input[type=text]").val(value).removeAttr 'placeholder'
    else if @isSelect attr
      $("##{attr} select").val(value).change()
    else
      $("##{attr} textarea").val value
      

  #- "category" input (select) change
  '#type select change': (el) ->
    $('#category select option[class!=label]').remove()
    if el.val().length > 0
      for category in $('option:selected',el).data 'categories'
        $('#category select').append "<option>#{category}</option>"

  #- input (select, text) focus
  'input[type=text], select focus': (el) ->
    $('input[type=checkbox]', el.parent()).attr 'checked', true

  #- input (select, text) blur - update Meta
  'input[type=text], textarea, select blur': (el) ->
    value = el.val().trim()
    value = value.replace /'/gi, '`'
    doUpdate = value.length > 0
    $('input[type=checkbox]', el.parent()).attr 'checked', doUpdate
    return if not doUpdate
    
    attribute = el.parent().attr 'id' 
    $('#imagelist li.selected').each (i, el) =>
      imageMeta = $(el).data 'image'
      imageMeta[attribute] = value
      $(el).data 'image', imageMeta