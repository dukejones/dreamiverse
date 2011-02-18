contextController = null

$(document).ready ->
  contextController = new ContextController('#contextPanel .profile')

class ContextController
  constructor: (containerSelector) ->
    @$container = $(containerSelector)
    
    @contextView = new ContextView(containerSelector)
    
    @$container.find('.change').click (event) =>
      @contextView.showEditProfile()
    
    @$container.find('.cancel').click (event) =>
      @contextView.showProfile()
    
    $('form#update_profile').bind 'ajax:beforeSend', (xhr, settings)->
      @contextView.showProfile()
    
    $('form#update_profile').bind 'ajax:success', (data, xhr, status)->
      $('p.notice').text('Profile has been updated')
    
    $('form#update_profile').bind 'ajax:error', (xhr, status, error)->
      $('p.alert').text(error)

class ContextView
  constructor: (containerSelector) ->
    @$container = $(containerSelector)
    @$viewPanel = @$container.find('.view')
    @$editPanel = @$container.find('.edit')
  showEditProfile: ->
    @$viewPanel.hide()
    @$editPanel.show()
  showProfile: ->
    @$viewPanel.show()
    @$editPanel.hide()