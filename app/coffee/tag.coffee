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
        #@$container.find('.tagAdd').click => $.publish 'tags:create', [@tagInput.value()]

    @tagInput = new @tagInputClass(@$container.find('#newTag'))
    @tagViews = new @tagViewListClass(@tagViewClass)

    $.subscribe 'tags:create', (tagName)=> 
      # Check for empty tag
      log @tagInput.$input.val()
      if @tagInput.$input.val() isnt ""
        @createTag(tagName)
    
    
  createTag: (tagName)->
    tag = new Tag(tagName)
    tagView = new @tagViewClass(tag)
    tagView.create()

    @tagViews.$container.append( tagView.createElement() )
    
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
    $('.tagThisEntry').click => @addExpandSubmitHandler()
    $('.tagHeader').click => @contractInputField()
    #$('#newTag').blur => @contractInputField()

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
    $('.tagInput').animate({width: '250px'})
  contractInputField: ->
    @buttonMode = 'expand'
    $('.tagThisEntry').removeClass('selected')
    $('.tagInput').animate({width: '0px'})
    


    
class TagViewList
  constructor: (tagViewClass)->
    @$container = $('#tag-list')
    @tagViews = []
    
    @tagViewClass = tagViewClass
    @addAllCurrentTags()
    
    @$container.find('.tag .close').live "click", (event)=>
      @removeTag($(event.currentTarget).parent().data('id'))
    
    #@$container.delegate 'div', 'click', (event)=>
    #  @removeTag($(event.currentTarget).data('id'))
    
    $.subscribe 'tags:remove', (id) =>
      @findByTagId(id).startRemoveFromView()
    
    $.subscribe 'tags:removed', (id) =>
      @findByTagId(id).removeFromView()
    
    # set up array functionality
    Array::remove = (e) -> @[t..t] = [] if (t = @.indexOf(e)) > -1
  
  addAllCurrentTags: ->
    # Fill up @tagViews with tags for each currently displayed tags
    for $currentElement in @$container.find('.tag')
      $element = $($currentElement)
      id = $element.data('id')
      name = $element.find('.tagContent').text()
      tag = new Tag(name, id)
      tagView = new @tagViewClass( tag )
      tagView.linkElement($element)
      @add(tagView)

  findByTagId: (tagId)->
    return tagView for tagView in @tagViews when tagView.tag.id == tagId

  add: (tagView)->
    if !@tagAlreadyExists(tagView)
      @tagViews.push(tagView)
      tagView.fadeIn()
  
  tagAlreadyExists: (tagView) ->
    tagString = tagView.tag.name
    for tagViewz in @tagViews
      if tagViewz.tag.name is tagString
        tagView.removeFromView()
        return true
    return false

  removeTag: (tagId) ->
    #log tagId
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
  createElement: ->
    @$element = $('.emptyTag').clone().show()
    @$element.removeClass('emptyTag')
    @$element.addClass('tag')
    @$element.addClass('tagWhat')
    @setValue(@tag.name)
    
    return @$element
  setValue: (tagName) ->
    @$element.find('.tagContent').html(tagName)
  setId: (id) ->
    @$element.attr('data-id', id)
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
    super()
    @createFormElement()
  
  create: ->
    @createElement()

  createFormElement: ->
    hiddenFieldString = @inputHtml.replace(/:tagName/, @tag.name)
    @$element.append(hiddenFieldString)
  remove: ->
    if $("#sorting").val() is "1"
      @removeFromView()
    
class ShowingTagView extends TagView
  # ask for ajax stuff
  constructor: (tag) ->
    super(tag)
  create: ->
    @tag.create().then (response)=>
      @setId(response.what_id)
      @tag.setId(response.what_id)
  remove: ->
    # FIX THIS HERE This if statement is not firing properly
    if $("#sorting").val() is "1"
      @removeFromView()
      @tag.destroy()


# MAKE THIS STORE THE ID OF THE TAG ALSO
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
      success: (data, status, xhr) =>
        $.publish 'tags:removed', [@id]
    }
    

    