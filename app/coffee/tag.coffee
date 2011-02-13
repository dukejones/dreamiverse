tagsController = null

$(document).ready ->
  setupTags()
  
setupTags = ->
  tagsController = new TagsController('.entryTags')

class TagsController
  constructor: (containerSelector)->
    @$container = $(containerSelector)

    @tagInput = new TagInput(@$container.find('#newTag'))
    @tagViews = new TagViewList(@$container.find('#tag-list'))

    @$container.find('.tagAdd').click => $.publish 'tags:create', [@tagInput.value()]

    $.subscribe 'tags:create', (tagName)=> @createTag(tagName)
    
  createTag: (tagName)->
    tagView = new TagView( new Tag(tagName) )
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
    
class TagViewList
  constructor: ->
    @$container = $('#tag-list')
    @tagViews = []
  add: (tagView)->
    @tagViews.push(tagView)
    @$container.append( tagView.createElement() )
    tagView.fadeIn()
    

class TagView
  inputHtml: '<input type="hidden" value=":tagName" name="what_tags[]" />'
  constructor: (tag)->
    @tag = tag
  createElement: ->
    @$element = $('#empty-tag').clone().attr('id', '').show()
    @setValue(@tag.name)
    @createFormElement()
    return @$element
  setValue: (tagName) ->
    @$element.find('.content').html(tagName)
  fadeIn: ->
    # TODO: This should pull the current bg color, change to dark, then animate up to the supposed-to color
    @$element.css('backgroundColor', '#777');
    setTimeout (=> @$element.animate {backgroundColor: "#ccc"}, 'slow'), 200
  createFormElement: ->
    hiddenFieldString = @inputHtml.replace(/:tagName/, @tag.name)
    @$element.append(hiddenFieldString)
    

# Tag Model
class Tag
  constructor: (name) ->
    @name = name
  create: ->
  destroy: ->
  
  
class OldTag
  constructor: (name) ->
    @$tagContainer = $(name)
    @$tagHeader = @$tagContainer.find('.tagHeader')
    @$tagsExpand = @$tagContainer.find('.target')
    @$tagsList = @$tagContainer.find('.tag-list')
    @$tagInput = @$tagContainer.find('#newTag')
    @$tagInputWrap = @$tagContainer.find('.tagInputWrap')
    @$tagAddButton = @$tagContainer.find('.tagAdd')
    @$tagCheck = @$tagContainer.find('.tagCheck')
    @$tagEntryButton = @$tagContainer.find('.tagThisEntry')
    
    $.subscribe 'tagToggle', (event) =>
      @toggleView()

    @$tagHeader.click (event) =>
      $.publish('tagToggle', [this])
    
    @$tagAddButton.click (event) =>
      @addTag()
    
    @$tagInput.keypress (event) =>
      if event.which is 13
        @addTag()
    
    if @$tagEntryButton
      @$tagEntryButton.click (event) =>
        @enableTags()
      
  enableTags: ->
    @$tagEntryButton.hide()
    
    @$tagCheck.unbind()
    @$tagCheck.click (event) =>
      @disableTags()
    
    @$tagCheck.show()
    @$tagInputWrap.show()
    
    @$tagInput.focus()
  
  disableTags: ->
    @$tagCheck.hide()
    @$tagInputWrap.hide()
    
    @$tagEntryButton.show()
    
  toggleView: ->
    if @$tagsList.is(":visible")
      @contract()
    else
      @expand()
    
  expand: ->
    # code to expand menu item
    @$tagsExpand.slideDown()
    
  contract: ->
    # code to contract menu item
    @$tagsExpand.slideUp()
    
  addTag: ->
    randomNumber = Math.round( Math.random() * 100001)
    @tagID = ('tagID_' + randomNumber)
    
    if @$tagInput.val()
      tag = $('#empty-tag').clone().attr('id', @tagID );
      @$tagsList.find('br').before(tag);
      
      tag.removeClass('hidden').find('.tagContent').html(@$tagInput.val())
      tag.css('background-color', '#ccc');
      
      # todo : this function is not running
      setTimeout( => 
        tag.animate({backgroundColor: "#333"}, 'slow')
      , 200)
      
      @$tagInput.val('')
      @$tagInput.focus()
    