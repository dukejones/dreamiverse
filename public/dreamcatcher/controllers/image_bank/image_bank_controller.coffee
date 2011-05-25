$.Controller 'Dreamcatcher.Controllers.ImageBank',

  ibModel: Dreamcatcher.Models.ImageBank
  
  init: ->
    @showWidget 'browser'
    @showWidget 'dropbox'
  
    
  showWidget: (widget, images, params, hideBrowser) ->
    $('#frame.browser').hide() if hideBrowser
    
    switch widget
    
      when 'browser'
        @browser = new Dreamcatcher.Controllers.ImageBank.Browser $("#frame.browser") if not @browser
        @browser.parent = this
        @browser.show()
    
      when 'dropbox'
        @dropbox = new Dreamcatcher.Controllers.ImageBank.Dropbox $("#dropbox") if not @dropbox
        @dropbox.parent = this
        @dropbox.show()
        
      when 'slideshow'
        @slideshow = new Dreamcatcher.Controllers.ImageBank.Slideshow $("#slideshow-back") if not @slideshow?
        index = params.index if params? and params.index?
        @slideshow.show images, index
      
      when 'searchOptions'
        @searchOptions = new Dreamcatcher.Controllers.ImageBank.SearchOptions $("#searchOptions") if not @searchOptions?
        @searchOptions.parent = this
        @searchOptions.show()
      
      when 'manager'
        @manager = new Dreamcatcher.Controllers.ImageBank.Manager $("#frame.manager") if not @manager?
        @manager.parent = this
        title = params.title if params? and params.title?
        @manager.show images, title
  
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
    images = @getImagesFromElements elements
    @lazyLoad '#slideshow-back', 'images/slideshow', 'slideshow', images, { index: index }
    
  showManager: (elements, title) ->
    images = @getImagesFromElements elements
    @lazyLoad '#frame.manager', 'images/manager', 'manager', images, { title: title }
      
  lazyLoad: (selector, path, widget, images, params) ->
    if not $(selector).exists()
      @ibModel.getHtml path, {}, (html) =>
        $('body').append html
        @showWidget widget, images, params, true
    else
      @showWidget widget, images, params, true
      
  #called from within browser
  addImageToDropbox: (el) ->
    @dropbox.addImage el
    
  registerDroppable: (el) ->
    @dropbox.registerDroppable el
  
  registerDraggable: (el, fromDropbox) ->
    @dropbox.registerDraggable el, fromDropbox
    
  getSearchOptions: ->
    options = {}
    options = @searchOptions.get() if @searchOptions?
    options['q'] = $(".searchField input[type='text']").val()
    return options