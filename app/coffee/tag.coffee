# Tag Model
class Tag
  constructor: (@name) ->
    @$tagContainer = $(@name)
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
    alert "add tag"
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
    