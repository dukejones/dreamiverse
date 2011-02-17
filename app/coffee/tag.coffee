class window.TagsController
  constructor: (containerSelector, mode='edit')->
    @$container = $(containerSelector)
    
    switch mode
      when 'edit'
        @tagViewClass = EditingTagView
        @tagInputClass = TagInput
        @$container.find('.tagAdd').click => $.publish 'tags:create', [@tagInput.value()]
      when 'show'
        @tagViewClass = ShowingTagView
        @tagInputClass = ShowingTagInput
        #@$container.find('.tagAdd').click => $.publish 'tags:create', [@tagInput.value()]

    @tagInput = new @tagInputClass(@$container.find('#newTag'))
    @tagViews = new TagViewList(@tagViewClass)

    $.subscribe 'tags:create', (tagName)=> @createTag(tagName)
    
    
  createTag: (tagName)->
    tag = new Tag(tagName)
    tag.attachToEntry()
    tagView = new @tagViewClass(tag)
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
    
    $('.tagInput').css('width', '0px')
    $('.tagThisEntry').click => @addExpandSubmitHandler()
    $('.tagHeader').click => @contractInputField()
  
  addExpandSubmitHandler: ->
    switch @buttonMode
      when 'expand'
        @expandInputField()
      when 'submit' then $.publish 'tags:create', [@value()]
  
  expandInputField: ->
    @buttonMode = 'submit'
    $('.tagInput').animate({width: '250px'})
  contractInputField: ->
    @buttonMode = 'expand'
    $('.tagInput').animate({width: '0px'})
    


    
class TagViewList
  constructor: (tagViewClass)->
    @$container = $('#tag-list')
    @tagViews = []
    
    @tagViewClass = tagViewClass
    
    # Fill up @tagViews with tags for each currently displayed tags
    
    #tagView = new @tagViewClass( new Tag(tagName) )
    i = 0
    to = @$container.find('.tag').length - 1
    while i <= to
      $element = @$container.find('.tag').eq(i)
      
      newId = $element.data('id')
      tagName = $element.find('.tagContent').text()
      
      tag = new Tag(tagName)
      tag.setId(newId)
      
      tagView = new @tagViewClass(tag)
      tagView.linkElement($element)
      
      @attach(tagView)
      i++
      
    
    @$container.delegate 'div', 'click', (event)=>
      @removeTag($(event.currentTarget).data('id'))
    
    $.subscribe 'tags:remove', (id) =>
      @findByTagId(id).startRemoveFromView()
    
    $.subscribe 'tags:removed', (id) =>
      @findByTagId(id).removeFromView()
  
  findByTagId: (tagId)->
    return tagView for tagView in @tagViews when tagView.tag.id == tagId

  attach: (tagView)->
    @tagViews.push(tagView)
    tagView.fadeIn()
  
  add: (tagView)->
    @tagViews.push(tagView)
    @$container.append( tagView.createElement() )
    @$container.slideDown()
    tagView.fadeIn()
    
  removeTag: (tagId) ->
    tagToRemove = @findByTagId(tagId)
    log tagToRemove
    tagToRemove.tag.removeTag()
    

class TagView
  constructor: (tag)->
    @tag = tag
    $.subscribe 'tags:id', (id) => @setId(id)
    
  tagNode: -> @tag
  linkElement: (element)->
    @$element = element
  createElement: ->
    @$element = $('#empty-tag').clone().attr('id', '').show()
    @$element.addClass('tagWhat')
    @setValue(@tag.name)
    
    return @$element
  setValue: (tagName) ->
    @$element.find('.tagContent').html(tagName)
  setId: (id) ->
    @$element.attr('data-id', id)
  fadeIn: ->
    # TODO: This should pull the current bg color, change to dark, then animate up to the supposed-to color
    currentBackground = @$element.css('backgroundColor');
    @$element.css('backgroundColor', '#777');
    setTimeout (=> @$element.animate {backgroundColor: currentBackground}, 'slow'), 200
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

  createFormElement: ->
    hiddenFieldString = @inputHtml.replace(/:tagName/, @tag.name)
    @$element.append(hiddenFieldString)
  
class ShowingTagView extends TagView
  # ask for ajax stuff
  constructor: (tag) ->
    super(tag)

# MAKE THIS STORE THE ID OF THE TAG ALSO
# Tag Model
class Tag
  constructor: (name) ->
    @name = name
    #@attachToEntry()
  setId: (id) ->
    @id = id
  attachToEntry: ->
    @entry_id = $('#showEntry').data('id')
    $.ajax {
      type: 'POST'
      url: '/tags'
      data:
        entry_id: @entry_id
        what_name: @name
      success: (data, status, xhr) =>
        @id = data.what_id
        $.publish 'tags:id', [@id]
    }
    #$.post "/tags", { entry_id: @entry_id, what_name: @name }, (data) -> alert "Data Loaded: " + data
  removeTag: ->
    $.publish 'tags:remove', [@id]
    $.ajax {
      type: 'DELETE'
      url: '/tags/what'
      data:
        entry_id: @entry_id
        what_id: @id
      success: (data, status, xhr) =>
        $.publish 'tags:removed', [@id]
    }
    

    