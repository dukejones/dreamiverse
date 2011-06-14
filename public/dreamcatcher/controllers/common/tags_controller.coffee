$.Controller.extend 'Dreamcatcher.Controllers.Common.Tags', {
  pluginName: 'tags'
},{

  model: {
    tag: Dreamcatcher.Models.Tag
  }
   
  init: (el, mode='edit') ->
    @element = el
    @mode = mode
    @buttonMode = 'expand'
    log "loaded tags controller @mode: #{@mode}"
    switch mode
      when 'show'
        $('.tagAnalysis .trigger').live( 'click', (event ) ->
          $(this).parent().toggleClass('expanded')
        )

  
  appendTag: (tagName) ->     
    tagCount = @tagCount()
    if tagName.length > 1 and tagCount < 16 and !@alreadyExists tagName
      html = $.View('//dreamcatcher/views/common/tags/show.ejs', {tagName: tagName, mode: @mode})
      $('#tag-list').append html
      $('#newTag').val ''

  alreadyExists: (tagName) ->
    exists = false
    # Check both custom and auto tag lists
    $('.tag-list .tag-name').each (i, el) =>
      tag = $(el).text().trim()
      if (tagName is tag)
        exists = true  
    return exists
     
  removeTagFromDom: (el) ->
    @tag = el
    @tag.css('backgroundColor', '#ff0000')  
    @tag.fadeOut 'fast', =>
      @tag.parent().remove()
    
  getTag: -> $('#newTag').val().replace('/','').replace(',','').trim()
  
  expandContractInputField: ->
    if @buttonMode is 'expand'
      @expandInputField()
    else
      @contractInputField()
        
  expandInputField: ->
    @buttonMode = 'submit'
    $('.tagThisEntry').addClass 'selected'
    $('.tagInput').animate {width: '200px'}
    $('#newTag').focus()
    
  contractInputField: ->
    @buttonMode = 'expand'
    $('.tagThisEntry').removeClass 'selected'
    $('.tagInput').animate {width: '0px'}
    $('#newTag').blur()

  tagCount: ->
    count = 0
    for el in $('#tag-list .tag')
      count = count + 1
    log "tagCount #{count}"
    return count
      
  # DOM Listeners
  
  '.tagThisEntry click': ->
    if @buttonMode is 'expand'
      @expandInputField()
    else
      $('.tagAdd').click()
  
  '.tagHeader click': -> @expandContractInputField()
  
  '#newTag keyup': (el, ev) ->
    if ev.keyCode is 188 or ev.keyCode is 13 or ev.keyCode is 191 # ',', 'enter' and '/'
      $('#addTag').click()

  '#addTag click': (el) ->
    tagName = @getTag()
    log "tagAdd click mode #{@mode}"
    switch @mode
      when 'edit' 
        @appendTag tagName
      when 'show'
        log 'show mode'
        @appendTag tagName
        # entryId = $('#showEntry').data 'id' 
        # @model.tag.create {
        #   entry_id: entryId
        #   what_name: tagName
        # }, @callback('appendTag', tagName)

  '#tag-list .tag .close click': (el) ->
    @removeTagFromDom(el.parent())
  
  '#tag-list .tag .close click': (el) ->
    @removeTagFromDom(el.parent())
       
}
