$.Controller.extend 'Dreamcatcher.Controllers.Common.Tags', {
  pluginName: 'tags'
},{

  model: {
    tag: Dreamcatcher.Models.Tag
  }

  init: (el, mode='edit') ->
    @element = el
    @mode = mode
    
  
  '#newTag keyup': (el, ev) ->
    if ev.keyCode is 188 or ev.keyCode is 13 or ev.keyCode is 191 # ',', 'enter' and '/'
      $('.tagAdd').click()
  
  getTag: -> $('#newTag').val().replace('/','').replace(',','').trim()
  
  '.tagAdd click': (el) ->
    tagName = @getTag()
    
    switch @mode
      when 'new'
        @appendTag tagName unless @alreadyExists tagName
        
      when 'edit'
        log 'editMode'
        ###
        entryId = $('#showEntry').data 'id' 
        @model.tag.create {
          entry_id: entryId
          what_name: tagName
        }, @callback('appendTag', tagName)
        ###

  alreadyExists: (tagName) ->
    exists = false
    $('#tag-list .tag-name').each (i, el) =>
      tag = $(el).text().trim()
      if (tagName is tag)
        exists = true
    return exists

  appendTag: (tagName) ->
    html = $.View('//dreamcatcher/views/common/tags/show.ejs', {tagName: tagName})
    $('#tag-list').append html
    $('#newTag').val ''
    
}