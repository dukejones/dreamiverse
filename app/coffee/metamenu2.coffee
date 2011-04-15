$(document).ready ->
  metaMenuController = new MetaMenuController()

class MetaMenuController
  constructor: (@name)->
    @$currentMenuButton = $(@name).find('.trigger').first()
    @$currentMenuPanel = $(@name).find('.target').first()

    ###
    @metaMenu = new MetaMenuModel()
    @metaMenuView = new MetaMenuView(@metaMenuView)
    
    #logic here

class MetaMenuView
  constructor: (metaMenuModel) ->
    #logic here

class MetaMenuModel
  load: (filters={})->
    #logic here
###    
    
class AppearencePanelController extends MetaMenuController
  constructor: (@name) ->
    super(@name)
    
    @appearencePanel = new MetaMenuModel()
    @appearencePanelView = new MetaMenuView(@appearencePanel)
    ###
    $.subscribe('toggleAppearance', (event) ->
      appearancePanel.contract()
      settingsPanel.contract()
      $('.item.settings').removeClass('selected')
    
      appearancePanel.toggleView()
    )
    ###

    
class AppearencePanelView
  constructor: (appearencePanelModel) ->
    @appearencePanel = appearencePanelModel
  
  initBedsheets: ->
    if not $('#appearancePanel').attr('id')
      return
    ###
    @appearencePanel.load().then(data) =>
      @$currentMenuPanel.find('.bedsheets ul').html('');
    
        # Add elements for each bedsheet returned
        for node in data
          newElement = '<li data-id="' + node.id + '"><img src="/images/uploads/' + node.id + '-thumb-120.jpg"></li>'
          @$currentMenuPanel.find('.bedsheets ul').append(newElement)
        
        # set bedsheet
        @$currentMenuPanel.find('.bedsheets ul').find('li').click (event) =>
          bedsheetUrl = 'url("/images/uploads/' + $(event.currentTarget).data('id') + '-bedsheet.jpg")'
          $('#body').css('background-image', bedsheetUrl)
      
          if $('#entry_view_preference_attributes_image_id').attr('name')?
            $('#entry_view_preference_attributes_image_id').val($(event.currentTarget).data('id'))
          else if $('#show_entry_mode').attr('name')? 
            @updateEntryViewPreferences($('#showEntry').data('id'),$(event.currentTarget).data('id'),null,null)  
          else
            @updateUserViewPreferences($(event.currentTarget).data('id'),null,null)           
     ###
    
  
  
class AppearencePanelModel
  load: () ->
    $.getJSON("/images.json?section=Bedsheets", {}).promise()
    
  updateUserViewPreferences: (@bedsheetId,@scrolling,@theme) ->
    $.ajax {
      type: 'POST'
      url: "/entries/#{@entryId}/set_view_preferences"
      data:
        bedsheet_id: @bedsheetId if @bedsheetId?
        scrolling: @scrolling if @scrolling?
        theme: @theme if @theme?
        success: (data, status, xhr) ->
          success = true
     }
     
  updateEntryViewPreferences: (@entryId,@bedsheetId,@scrolling,@theme) ->
    $.ajax {
      type: 'POST'
      url: "/user/set_view_preferences"
      data:
        bedsheet_id: @bedsheetId if @bedsheetId?
        scrolling: @scrolling if @scrolling?
        theme: @theme if @theme?
        success: (data, status, xhr) ->
          success = true
     }
