$.Controller.extend 'Dreamcatcher.Controllers.Common.Tags', {
  pluginName: 'tags'
},{

  model: {
    tag: Dreamcatcher.Models.Tag
  }
   
  init: (el, mode='edit') ->
    @element = el
    @mode = mode
    @clickEvent = if (navigator.userAgent.match(/iPad/i)) then "touchstart" else "click"  
  

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
     
  removeTagFromDom: (tagId) ->
    $("##{tagId}").remove()

  getTag: -> $('#newTag').val().replace('/','').replace(',','').trim()

  # DOM Listeners
  '#newTag keyup': (el, ev) ->
    if ev.keyCode is 188 or ev.keyCode is 13 or ev.keyCode is 191 # ',', 'enter' and '/'
      $('.tagAdd').click()
      return false

  '.tagAdd click': (el) ->
    tagName = @getTag()
    log 'clickEvent: ' + @clickEvent
    switch @mode
      when 'new'
        @appendTag tagName unless @alreadyExists tagName
      when 'edit'
        log 'edit mode'
        # entryId = $('#showEntry').data 'id' 
        # @model.tag.create {
        #   entry_id: entryId
        #   what_name: tagName
        # }, @callback('appendTag', tagName)
    
  # $('#tag-list').find('.tag .close').live @clickEvent, (ev) =>
    # @removeTagFromDom($(ev.currentTarget).parent().data('id'))    
  
}

# $(document).ready ->
#   clickEvent = if (navigator.userAgent.match(/iPad/i)) then "touchstart" else "click" 
#   $('#tag-list').find('.tag .close').live 'click', (event)=>
#     log 'delete'
#     # @removeTagFromDom($(event.currentTarget).parent().data('id'))
