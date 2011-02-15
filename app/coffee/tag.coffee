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
    @tagViews = new TagViewList(@$container.find('#tag-list'))

    $.subscribe 'tags:create', (tagName)=> @createTag(tagName)
    
    @$container.find('.tag-list div').live 'click', =>
      # How do I tell this tag to delete itself?
      alert "tag clicked"
    
  createTag: (tagName)->
    tagView = new @tagViewClass( new Tag(tagName) )
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
  
  addExpandSubmitHandler: ->
    switch @buttonMode
      when 'expand'
        @expandInputField()
      when 'submit' then $.publish 'tags:create', [@value()]
  
  expandInputField: ->
    @buttonMode = 'submit'
    $('.tagInput').animate({width: '250px'})
    


    
class TagViewList
  constructor: ->
    @$container = $('#tag-list')
    @tagViews = []
  add: (tagView)->
    @tagViews.push(tagView)
    @$container.append( tagView.createElement() )
    @$container.slideDown()
    tagView.fadeIn()
    

class TagView
  constructor: (tag)->
    @tag = tag
  createElement: ->
    @$element = $('#empty-tag').clone().attr('id', '').show()
    @$element.addClass('tagWhat')
    @setValue(@tag.name)
    
    return @$element
  setValue: (tagName) ->
    @$element.find('.tagContent').html(tagName)
  fadeIn: ->
    # TODO: This should pull the current bg color, change to dark, then animate up to the supposed-to color
    currentBackground = @$element.css('backgroundColor');
    @$element.css('backgroundColor', '#777');
    setTimeout (=> @$element.animate {backgroundColor: currentBackground}, 'slow'), 200

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


# Tag Model
class Tag
  constructor: (name) ->
    @name = name
    @attachToEntry()
  attachToEntry: ->
    @entry_id = $('#showEntry').data('id')
    $.post "/tags", { entry_id: @entry_id, what_name: @name }, (data) ->
      alert "Data Loaded: " + data
  removeTag: ->
    deleteObj = 
      type: 'DELETE'
      url: '/tags'
      data:
        entry_id: @entry_id
        what_name: @name
    $.ajax deleteObj
    

    