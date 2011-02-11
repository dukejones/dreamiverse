
class window.TagController
  constructor: (containerSelector)->
    @$container = $(containerSelector)
    @tagViews = []

    @tagInputView = new TagInputView(@$container.find('#newTag'))
    # new TagList(@$container.find('.tag-list'))
    @$container.find('.tagAdd').click => @create()
    

  create: ->
    $entryForm = $('#new_entry')
    # get text
    tagName = @tagInputView.value()
    # create tag
    tag = new Tag($entryForm, tagName)
    tag.create()
    # show it
    @tagViews.push(new TagView(tag))
    
# class TagList
#   constructor: ($list)->
#     @$element = $list
    

class TagInputView
  constructor: ($input)->
    @$input = $input
    
  value: ->
    @$input.val()
    
    
class TagView
  constructor: (tag)->
    @tag = tag
    # append a tagview element to the list of tags
    @create()
  create: ->
    @$element = $('#empty-tag').clone().show()
    @setValue(@tag.name)
  setValue: (tagName) ->
    @$element.find('.tagContent').html(tagName)
    

# Tag Model
# <input type="hidden" value="unicorn" name="what_tags[]" id="what_tags_">
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
    