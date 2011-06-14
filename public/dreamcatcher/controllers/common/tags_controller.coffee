$.Controller.extend 'Dreamcatcher.Controllers.Common.Tags', {
  pluginName: 'tags'
},{

  model: {
    tag: Dreamcatcher.Models.Tag
  }
   
  init: (el, mode='edit') ->
    @element = el
    @mode = mode
    log "loaded tags controller @mode: #{@mode}"

  alreadyExists: (tagName) ->
    exists = false
    $('#tag-list .tag-name').each (i, el) =>
      tag = $(el).text().trim()
      if (tagName is tag)
        exists = true
    return exists
  
  appendTag: (tagName) ->
    html = $.View('//dreamcatcher/views/common/tags/show.ejs', {tagName: tagName, mode: @mode})
    $('#tag-list').append html
    $('#newTag').val ''
     
  removeTagFromDom: (tagId = null, tagEl) ->
    # log "tagId #{tagId} tagName: #{tagName}"
    @tag = if tagId? then $("##{tagId}") else tagEl # tagName.find('.tag-name').text() 
    @tag.css('backgroundColor', '#ff0000')  
    @tag.fadeOut 'fast', =>
      @tag.remove()
    
  getTag: -> $('#newTag').val().replace('/','').replace(',','').trim()
  
  # DOM Listeners
  '#newTag keyup': (el, ev) ->
    if ev.keyCode is 188 or ev.keyCode is 13 or ev.keyCode is 191 # ',', 'enter' and '/'
      $('.tagAdd').click()

  '.tagAdd click': (el) ->
    tagName = @getTag()
    switch @mode
      when 'edit'
        log 'edit mode'
        @appendTag tagName unless @alreadyExists tagName
      when 'show'
        log 'show mode'
        # entryId = $('#showEntry').data 'id' 
        # @model.tag.create {
        #   entry_id: entryId
        #   what_name: tagName
        # }, @callback('appendTag', tagName)

  '#tag-list .tag .close click': (el) ->
    @removeTagFromDom(null,el.parent())
        
  # '#tag-list .tag .close click': (el) ->
  #   @removeTagFromDom($(el).parent().data('id'))
  # 
  # '#tag-list .tag .close touchstart': (el) ->
  #   @removeTagFromDom($(el).parent().data('id'))
   
  
}
