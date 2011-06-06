$.Controller 'Dreamcatcher.Controllers.ImageBank.SearchOptions',

  model: Dreamcatcher.Models.Image
  
  getView: (url, data) ->
    return @view "//dreamcatcher/views/image_bank/search_options/#{url}.ejs", data
  
  init: ->
    $('#searchOptions .type').html @getView('types', {types: @model.types})

  show: (params) ->
    $("#searchOptions .type li").removeClass 'selected'
    $("#searchOptions .categories li").remove()
    
    if params?      
      $("#searchOptions .type li:contains(#{params.type})").click() if params.type?
      $("#searchOptions .category:contains(#{params.category})").click() if params.category?
      @setValueForAttribute 'artist', params.artist if params.artist?
    
    $('#searchOptions').show()
    
  get: ->
    options = {}
    
    if $("#searchOptions").is ":visible"

      for attr in ['artist','album','title','year','tags']
        val = @getValueFromAttribute attr
        options[attr] = val if val?

      categories = []
      $("#searchOptions .categories .selected").each (i, el) ->
        categories.push $(el).text().trim()
      options['categories'] = categories.join(',') if categories.length > 0

    return options
    

  getValueFromAttribute: (attr) ->
    inputElement = $("#searchOptions input[name='#{attr}']")
    val = inputElement.val().trim() if inputElement.val()?
    return val if val.length > 0
    return null
    
  setValueForAttribute: (attr, val) ->
    $("#searchOptions input[name='#{attr}']").val val


    
  '.type li click': (el) ->
    type = el.text().trim()
    if el.hasClass 'selected'
      el.removeClass 'selected'
      $("#searchOptions .categories div[data-type='#{type}']").remove()
    else
      el.addClass 'selected'
      categories = el.data('categories').split ','
      $('#searchOptions .categories').append @getView 'categories', {
        type: type
        categories: categories
      }
    
  '.category click': (el) ->
    if el.hasClass("selected") then el.removeClass("selected") else el.addClass("selected")


