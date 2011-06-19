$.Controller.extend 'Dreamcatcher.Controllers.Common.Tags', {
  pluginName: 'tags'
},{

  model: {
    tag: Dreamcatcher.Models.Tag
  }
   
  init: (scope, mode='edit') ->
    @scope = $(scope)
    @mode = mode
    @buttonMode = 'expand'
    #log "loaded tags controller @mode: #{@mode}"
    
  getTag: -> $('.newTag:first', @scope).val().replace('/','').replace(',','').trim()    
    
  addTag: ->
    tagName = @getTag()
    tagCount = @countTags()
    return if tagName.length < 2 or tagCount > 16 or @alreadyExists tagName

    if @mode is 'edit' 
      @appendTag tagName
    else if @mode is 'show'     
      entryId = $('.entry', @scope).data 'id' 
      @model.tag.create {
        entry_id: entryId
        what_name: tagName
      }, @callback('appendTag', tagName)  
          
  appendTag: (tagName, json=null) ->
    tagId = if json? then json.what_id else -1
    html = $.View('/dreamcatcher/views/common/tags/show.ejs', {tagName: tagName, tagId: tagId, mode: @mode})
    $('.custom.tag-list', @scope).append html
    $('.newTag', @scope).val ''
       
  # Check both custom and analysis tag lists
  alreadyExists: (tagName) ->
    exists = false
    # Check both custom and auto tag lists
    $('.tag-list .tag-name', @scope).each (i, el) =>
      tag = $(el).text().trim()
      if tagName is tag
        exists = true 
        $('.newTag:first', @scope).val '' 
    return exists
    
  removeTag: (el) ->
    tagId = $(el).parent().data 'id' 
    entryId = $('.entry', @scope).data 'id'    

    if @mode is 'edit' 
      @removeTagFromDom(el)    
    else if @mode is 'show'
      @model.tag.delete {
        entry_id: entryId
        what_id: tagId
      }, @callback('removeTagFromDom', el)
   
  removeTagFromDom: (el) ->
    @tag = el.parent()
    @tag.css('backgroundColor', '#ff0000')  
    @tag.fadeOut 'fast', =>
      @tag.remove()
  
  countTags: ->
    count = 0
    for el in $('.tag-list .tag', @scope)
      count += 1
    return count

  expandInputField: ->
    @buttonMode = 'submit'
    $('.tagThisEntry', @scope).addClass 'selected'
    $('.tagInput', @scope).animate {width: '200px'}
    $('.newTag', @scope).focus()

  contractInputField: ->
    @buttonMode = 'expand'
    $('.tagThisEntry', @scope).removeClass 'selected'
    $('.tagInput', @scope).animate {width: '0px'}
    $('.newTag', @scope).blur()

  expandContractInputField: ->
    if @buttonMode is 'expand'
      @expandInputField()
    else
      @contractInputField()

        
  # DOM Listeners
  
  '.tagAdd click': (el, ev) ->
    @addTag()
          
  '.tagThisEntry click': ->
    if @buttonMode is 'expand'
      @expandInputField()
    else
      @addTag()
  
  '.tagHeader click': -> @expandContractInputField()
  
  '.newTag keyup': (el, ev) ->
    if ev.keyCode is 188 or ev.keyCode is 13 or ev.keyCode is 191 # ',', '/' and 'enter'
      @addTag()
      return false

  '.tag-list .tag .close click': (el) ->
    @removeTag el
  
  '.tag-list .tag .close touchstart': (el) -> 
    @removeTagFromDom el.parent()
    
  '.tagAnalysis .trigger click': (el) ->
    if @mode is 'show'
      $(el).parent().toggleClass 'expanded'
            
}
