$.Controller 'Dreamcatcher.Controllers.IbSearchOptions',

  model: Dreamcatcher.Models.ImageBank

  
  init: ->
    $('#searchOptions .type').html @view('types', {types: @model.types})
    $("#searchOptions .type li").removeClass 'selected'
    $("#searchOptions .type li:contains(#{@type})").click()


  show: ->
    $('#searchOptions').show()
    
  get: ->
    options = {}
    
    if $("#searchOptions").is(":visible")

      for attr in ['artist','album','title','year','tags']
        val = @getValFromAttr attr
        options[attr] = val if val?

      categories = []
      $("#searchOptions .categories .selected").each (i, el) ->
        categories.push $(el).text().trim()
      options['categories'] = genres.join(',') if categories.length > 0

    return options
    

  getValFromAttr: (attr) ->
    inputElement = $("##{attr} input[type='text']");
    val = inputElement.val().trim() if inputElement.val()?
    return val if val.length > 0
    return null


    
  '.type li click': (el) ->
    type = el.text().trim()
    if el.hasClass 'selected'
      el.removeClass 'selected'
      $("#searchOptions .categories div[data-type='#{type}']").remove()
    else
      el.addClass 'selected'
      categories = el.data('categories').split ','
      $('#searchOptions .categories').append @view 'categories', {
        type: type
        categories: categories
      }
    
  '.category click': (el) ->
    if el.hasClass("selected") then el.removeClass("selected") else el.addClass("selected")


