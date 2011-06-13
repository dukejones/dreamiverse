class window.TagsController
  constructor: (containerSelector, mode='edit')->
    @$container = $(containerSelector)


    switch mode
      when 'edit'
        @tagViewClass = EditingTagView
        @tagInputClass = TagInput
        @tagViewListClass = EditingTagViewList
        @$container.find('.tagAdd').click => $.publish 'tags:create', [@tagInput.value()]
      when 'show'
        @tagViewClass = ShowingTagView
        @tagInputClass = ShowingTagInput
        @tagViewListClass = TagViewList
        $('.tagAnalysis .trigger').live( 'click', (event)->
          $(this).parent().toggleClass('expanded')
        )
        #@$container.find('.tagAdd').click => $.publish 'tags:create', [@tagInput.value()]

    @tagInput = new @tagInputClass(@$container.find('#newTag'))
    @tagViews = new @tagViewListClass(@tagViewClass)

    $.subscribe 'tags:create', (tagName)=> 
      # Check for empty tag & less than 3 char tag & default tag
      # Don't let them post unless they meet all the criteria
      if tagName isnt "" and tagName isnt "who/where/what" and tagName.length > 1
        
        # Check for max tags
        if @tagViews.tagViews.length < 17
          @createTag(tagName)
  

  createTag: (tagName)->     
    # if comma or slash delimited, split into an array of tags and append each one
    if /,/.test(tagName) 
      tagNames = tagName.split(/,+/)
      @appendTag tag for tag in tagNames
    else if /\//.test(tagName) 
      tagNames = tagName.split(/\/+/)
      @appendTag tag for tag in tagNames
    else
      @appendTag tagName

  appendTag: (tagName)->
    tag = new Tag(tagName)
    tagView = new @tagViewClass(tag)    
    if (!@tagViews.tagAlreadyExists(tagView))
      tagView.appendTo(@tagViews.$container)
      @tagViews.add(tagView)

class TagInput
  constructor: ($input)->
    @$input = $input

    @$input.keypress (event) =>
      if event.which is 13
        $.publish 'tags:create', [@value()]
        return false

    $.subscribe 'tags:create', => @clear()
  value: -> @$input.val()
  clear: -> @$input.val('')
  
class ShowingTagInput extends TagInput
  constructor: ($input)->
    super($input)
    @buttonMode = 'expand'
    
    #$('.tagInput').css('width', '0px')
    $('.tagThisEntry').click =>
      @addExpandSubmitHandler()
    $('.tagHeader').click => @expandContractInputField()
  
  expandContractInputField: ->
    switch @buttonMode
      when 'expand'
        @expandInputField()
      when 'submit'
        @contractInputField()
  
  addExpandSubmitHandler: ->
    switch @buttonMode
      when 'expand'
        @expandInputField()
      when 'submit'
        # check if field is empty
        $.publish 'tags:create', [@value()]
  
  expandInputField: ->
    @buttonMode = 'submit'
    $('.tagThisEntry').addClass('selected')
    $('.tagInput').animate({width: '200px'})
    $('#newTag').focus()
  contractInputField: ->
    @buttonMode = 'expand'
    $('.tagThisEntry').removeClass('selected')
    $('.tagInput').animate({width: '0px'})
    $('#newTag').blur()
    


    
class TagViewList
  constructor: (tagViewClass)->
    @$container = $('#tag-list')
    @tagViews = []
    
    @tagViewClass = tagViewClass
    @addAllCurrentTags()
    
    clickEvent = if (navigator.userAgent.match(/iPad/i)) then "touchstart" else "click"
    
    @$container.find('.tag .close').live clickEvent, (event)=>
      @removeTag($(event.currentTarget).parent().data('id'))
    
    #@$container.delegate 'div', 'click', (event)=>
    #  @removeTag($(event.currentTarget).data('id'))
    
    $.subscribe 'tags:remove', (id) =>
      @findByTagId(id).startRemoveFromView()
    
    # set up array functionality
    Array::remove = (e) -> @[t..t] = [] if (t = @.indexOf(e)) > -1
  
  addAllCurrentTags: ->
    # Fill up @tagViews with tags for each currently displayed tags
    for currentElement in @$container.find('.tag')
      $element = $(currentElement)
      id = $element.data('id')
      name = $element.find('.tag-name').text()
      tag = new Tag(name, id)
      tagView = new @tagViewClass( tag )
      tagView.linkElement($element)
      @add(tagView)

  findByTagId: (tagId)->
    return tagView for tagView in @tagViews when tagView.tag.id == tagId
  findByName: (tagName)->
    return tagView for tagView in @tagViews when tagView.tag.name == tagName
  add: (tagView)->
    if !@tagAlreadyExists(tagView)
      @tagViews.push(tagView)
      tagView.fadeIn()
  
  tagAlreadyExists: (tagView) ->
    tagString = tagView.tag.name
    for tagViewz in @tagViews
      if tagViewz.tag.name is tagString
        return true
    return false

  removeTag: (tagId) ->
    tagViewToRemove = @findByTagId(tagId)
    tagViewToRemove.remove()
    @tagViews.remove(tagViewToRemove)

class EditingTagViewList extends TagViewList
  constructor: (tagViewClass)->
    @$container = $('#tag-list')
    @tagViews = []
    
    @tagViewClass = tagViewClass
    @addAllCurrentTags()
    
    @$container.find('.tag').live "click", (event)=>
      @removeTag($(event.currentTarget))
    
    #@$container.delegate 'div', 'click', (event)=>
    #  @removeTag($(event.currentTarget).data('id'))
    
    $.subscribe 'tags:remove', (id) =>
      @findByTagId(id).startRemoveFromView()
    
    $.subscribe 'tags:removed', (id) =>
      @findByTagId(id).removeFromView()
      
  removeTag: ($tag) ->
    tagName = $tag.find('.tag-name').text()
    
    
    new_tags = (tag for tag in @tagViews when tag.tag.name != tagName)  
    
    @tagViews = new_tags
    $tag.css('backgroundColor', '#ff0000')
    $tag.fadeOut('fast', =>
      $tag.remove()
    )

class TagView
  constructor: (tag)->
    @tag = tag
    
  tagNode: -> @tag
  linkElement: (element)->
    @$element = element
  setValue: (tagName) ->
    @$element.find('.tag-name').html(tagName)
  setId: (id) ->
    @$element.attr('data-id', id)
    @tag.setId(id)
  fadeIn: ->
    # TODO: This should pull the current bg color, change to dark, then animate up to the supposed-to color
    #currentBackground = @$element.css('backgroundColor');
    #@$element.css('backgroundColor', '#777');
    #setTimeout (=> @$element.animate {backgroundColor: currentBackground}, 'slow'), 200
  startRemoveFromView: ->
    @$element.css('backgroundColor', '#ff0000')
  removeFromView: ->
    @$element.fadeOut('fast', =>
      @$element.remove()
    )
    

class EditingTagView extends TagView
  inputHtml: '<input type="hidden" value=":tagName" name="what_tags[]" />'
  createElement: ->
    @$element = $('.emptyTag').clone()
    @$element.removeClass('hidden emptyTag')
    @setValue(@tag.name)
    
    hiddenFieldString = @inputHtml.replace(/:tagName/, @tag.name)
    @$element.append(hiddenFieldString)
    @$element
  appendTo: ($container)->
    $container.append( @createElement() )

  remove: ->
    #if $("#sorting").val() is "1"
    @removeFromView()
    
class ShowingTagView extends TagView
  # ask for ajax stuff
  constructor: (tag) ->
    super(tag)
  appendTo: ($container)->
    @tag.create().then (response)=>
      @$element = $(response.html)
      @setId(response.what_id)
      $container.append( @$element )
      
  remove: ->
    # FIX THIS HERE This if statement is not firing properly
    #if $("#sorting").val() is "1"
    @removeFromView()
    @tag.destroy()


# Tag Model
class Tag
  constructor: (name, id = '') ->
    @name = name
    @id = id
  entryId: -> $('#showEntry').data('id')
  setId: (id)-> @id = id
  create: ->
    deferred = $.post "/tags", { entry_id: @entryId(), what_name: @name }, (data)->
      @id = data.what_id
    return deferred.promise()
    
  destroy: ->
    $.publish 'tags:remove', [@id]
    
    $.ajax {
      type: 'DELETE'
      url: '/tags/what'
      data:
        entry_id: @entryId()
        what_id: @id
    }


