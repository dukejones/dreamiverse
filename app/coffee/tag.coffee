tagsController = null

$(document).ready ->
  setupTags()
  
setupTags = ->
  tagsController = new TagsController('.entryTags')

class TagsController
  constructor: (containerSelector)->
    @$container = $(containerSelector)

    @tagInputView = new TagInputView(@$container.find('#newTag'))
    @tagList = new TagList(@$container.find('#tag-list'))

    @$container.find('.tagAdd').click => $.publish 'tags:create'
    $.subscribe 'tags:create', => @createTag()
    

  create: ->
    $entryForm = $('#new_entry')
    tagName = @tagInputView.value()
    tag = new Tag($entryForm, tagName)
    tag.create()
    tagView = new TagView(tag)
    tagView.create()
    @tagViews.push(tagView)
    

class TagInputView
  constructor: ($input)->
    @$input = $input
    @$input.submit -> log "submit!"

    @$input.keypress (event) =>
      log event
      if event.which is 13
        $.publish 'tags:create'
    
  value: ->
    @$input.val()
    
class TagListView
  constructor: ->
    @$container = $('#tag-list')
    @tags = []

# Should TagView just have its own container, or should TagList hold a bunch of Tags?
class TagView
  constructor: (tag)->

    @tag = tag
  bind: ->
    # delegate tag click/etc functionality to the TagView container
  find: ->
    # search through existing tags and find the one with the tag name
  create: ->
    @$element = $('#empty-tag').clone().attr('id', '').show()
    @setTag(@tag.name)
    @$container.append(@$element)
    @fadeIn()
  setTag: (tagName) ->
    @$element.find('.content').html(tagName)
  fadeIn: ->
    # TODO: This should pull the current bg color, change to dark, then animate up to the supposed-to color
    @$element.css('backgroundColor', '#777');
    setTimeout (=> @$element.animate {backgroundColor: "#ccc"}, 'slow'), 200
    

# Tag Model
# <input type="hidden" value="unicorn" name="what_tags[]" id="what_tags_">
# is this really a model?
class Tag
  constructor: ($form, name) ->
    @$form = $form
    @name = name
  create: ->
    # add to the what_tags[] hidden fields
    hiddenFieldString = '<input type="hidden" value=":name" name="what_tags[]" />'
    hiddenFieldString = hiddenFieldString.replace(/:name/, @name)

    @$form.append(hiddenFieldString)
  destroy: ->
    # remove from the what_tags fields
    # add to the remove_what_tags fields
  
  
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
    