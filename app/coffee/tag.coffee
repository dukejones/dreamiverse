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
    tagView.fadeIn()
    

class TagView
  constructor: (tag)->
    @tag = tag
  createElement: ->
    @$element = $('#empty-tag').clone().attr('id', '').show()
    @setValue(@tag.name)
    
    return @$element
  setValue: (tagName) ->
    @$element.find('.content').html(tagName)
  fadeIn: ->
    # TODO: This should pull the current bg color, change to dark, then animate up to the supposed-to color
    @$element.css('backgroundColor', '#777');
    setTimeout (=> @$element.animate {backgroundColor: "#ccc"}, 'slow'), 200

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
  constructor: (tag)->
    super(tag)


# Tag Model
class Tag
  constructor: (name) ->
    @name = name

    