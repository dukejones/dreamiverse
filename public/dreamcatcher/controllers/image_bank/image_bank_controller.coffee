$.Controller 'Dreamcatcher.Controllers.ImageBank',

  model: Dreamcatcher.Models.ImageBank
  
  init: ->
    @showWidget 'browser'
    @showWidget 'dropbox'
  
    
  showWidget: (widget, images, params, hideBrowser) ->
    $('#frame.browser').hide() if hideBrowser
    
    switch widget
    
      when 'browser'
        @ibBrowser = new Dreamcatcher.Controllers.IbBrowser $("#frame.browser") if not @ibBrowser
        @ibBrowser.parent = this
        @ibBrowser.show()
    
      when 'dropbox'
        @ibDropbox = new Dreamcatcher.Controllers.IbDropbox $("#dropbox") if not @ibDropbox
        @ibDropbox.parent = this
        @ibDropbox.show()
        
      when 'slideshow'
        @ibSlideshow = new Dreamcatcher.Controllers.IbSlideshow $("#slideshow-back") if not @ibSlideshow?
        index = params.index if params? and params.index?
        @ibSlideshow.show images, index
      
      when 'searchOptions'
        @ibSearchOptions = new Dreamcatcher.Controllers.IbSearchOptions $("#searchOptions") if not @ibSearchOptions?
        @ibSearchOptions.parent = this
        @ibSearchOptions.show()
      
      when 'manager'
        @ibManager = new Dreamcatcher.Controllers.IbManager $("#frame.manager") if not @ibManager?
        @ibManager.parent = this
        title = params.title if params? and params.title?
        @ibManager.show images, title
  

  getImagesFromElements: (elements) ->
    images = []
    elements.each (i,el) =>
      images[i] = $(el).data 'image'
    return images
    
        
  showDropbox: ->
    @showWidget 'dropbox'
    
  showSearchOptions: ->
    @showWidget 'searchOptions'
    
  showSlideshow: (elements, index) ->
    @lazyLoad '#slideshow-back', 'images/slideshow', 'slideshow', @getImagesFromElements elements, { index: index }
    
  showManager: (elements, title) ->
    @lazyLoad '#frame.manager', 'images/manage', 'manager', @getImagesFromElements elements, { title: title }
      
  lazyLoad: (selector, path, widget, images, params) ->
    if not $(selector).exists()
      @model.getHtml path, {}, (html) =>
        $('body').append html
        @showWidget widget, images, params, true
    else
      @showWidget widget, images, params, true
      
      
  #called from within browser
  addImageToDropbox: (element) ->
    @ibDropbox.addImage imageElement
    
  registerDroppable: (elements) ->
    @ibDropbox.registerDroppable elements
  
  registerDraggable: (elements, fromDropbox) ->
    @ibDropbox.registerDraggable elements, fromDropbox
    
  getSearchOptions: ->
    return @ibSearchOptions.get() if @ibSearchOptions?
    return {}
      
  

