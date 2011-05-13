$.Class 'Dreamcatcher.Classes.CookieHelper',{},{

  init: (key) ->
    @key = key
  
  #- basic
  clear: ->
    $.cookie @key,null
  
  set: (value) ->
    #log value
    $.cookie @key,value
    
  get: ->
    return $.cookie @key
    
  #- collection
  getAll: ->
    return $.cookie(@key).split(",") if $.cookie(@key)?
    return null
  
  add: (id) ->
    id = id.toString()
    items = @getAll()
    if not items?
      $.cookie(@key,id)
    else if items.indexOf(id) is -1
      items.push(id)
      $.cookie(@key,items.join(","))
      log $.cookie(@key)
    else
      log "already exists"
      
  contains: (id) ->
    id = id.toString()
    items = @getAll()
    if items?
      return items.indexOf(id) isnt -1
    return false

  remove: (id) ->
    id = id.toString()
    items = @getAll()
    return if not items?
    
    newItems = items.filter (item) ->
      return item isnt id
    $.cookie(@key,newItems.join(","))
}