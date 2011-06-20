$.Controller 'Dreamcatcher.Controllers.Images.SearchOptions', {
  pluginName: 'searchOptions'
}, {

  model: Dreamcatcher.Models.Image
  
  getView: (url, data) ->
    return $.View "/dreamcatcher/views/images/search_options/#{url}.ejs", data
  
  init: (el) ->
    @scope = $(el)
    $('#searchOptions .type').html @getView('types', {types: @model.types})

  'images.search_options.show subscribe': (called, data) ->
    $("#searchOptions .type li").removeClass 'selected'
    $("#searchOptions .categories li").remove()
    
    if data?      
      $("#searchOptions .type li:contains(#{data.type})").click() if data.type?
      $("#searchOptions .category:contains(#{data.category})").click() if data.category?
      @setValueForAttribute 'artist', data.artist if data.artist?
    
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
    
}


