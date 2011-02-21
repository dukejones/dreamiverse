contextController = null

$(document).ready ->
  contextController = new ContextController('#contextPanel')

class ContextController
  constructor: (containerSelector) ->
    @$container = $(containerSelector + ' .profile')
    
    @contextView = new ContextView(containerSelector)
    
    @$container.find('.change').click (event) =>
      @contextView.showEditProfile()
    
    @$container.find('.cancel').click (event) =>
      @contextView.showProfile()
    
    $(containerSelector).find('.context').click (event) =>
      if @contextView.profileState() is 'none'
        @contextView.expandProfile()
      else
        @contextView.contractProfile()
    
    $('form#update_profile').bind 'ajax:beforeSend', (xhr, settings)=>
      @contextView.showProfile()
      @contextView.contractProfile()
    
    $('form#update_profile').bind 'ajax:success', (data, xhr, status)->
      $('p.notice').text('Profile has been updated')
    
    $('form#update_profile').bind 'ajax:error', (xhr, status, error)->
      $('p.alert').text(error)

class ContextView
  constructor: (containerSelector) ->
    @$container = $(containerSelector  + ' .profile')
    @$viewPanel = @$container.find('.view')
    @$editPanel = @$container.find('.edit')
    @$namePanel = @$container.find('.name')
    @$detailsPanel = @$container.find('.details')
  profileState: ->
    @$namePanel.css('display')
  showEditProfile: ->
    @$viewPanel.hide()
    @$editPanel.show()
  showProfile: ->
    @$viewPanel.show()
    @$editPanel.hide()
  expandProfile: ->
    @$namePanel.slideDown()
    @$detailsPanel.slideDown()
  contractProfile: ->
    @$namePanel.slideUp()
    @$detailsPanel.slideUp()