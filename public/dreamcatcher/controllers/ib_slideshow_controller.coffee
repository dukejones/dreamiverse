$.Controller 'Dreamcatcher.Controllers.IbSlideshow',

  model: Dreamcatcher.Models.ImageBank
  
  showSlideshow: (images) ->
    $('#slideshow-back,#slideshow').show()
    $('#slideshow .image img').attr 'src', "/images/uploads/originals/#{images[0].id}.#{images[0].format}"
    
  '.close click': (el) ->
    $('#slideshow-back').hide()
    
    
    
    ###
    images = []
    index = 0
    imageElements.each (i, el) =>
      images[i] = $(el).data 'image'
      index = i if imageId? and $(el).data('id') is imageId
    $("#slideshow").replaceWith @view('slideshow', { images: images })
    @showSlide index
    @displayScreen 'slideshow',null
    @setDraggable $('#slideshow .img')
    ###
  

  #- Slideshow -#

  ###
  '.footer .prev click': ->
    currentIndex = $("#slideshow .img:visible").index()
    @showSlide currentIndex - 1  

  '.footer .next click': ->
    currentIndex = $("#slideshow .img:visible").index()
    @showSlide currentIndex + 1
    ###

  ###
  '.footer .add click': (el) ->
    imageElement = $("#slideshow img:visible")
    imageId = imageElement.data 'id' 
    imageMeta = imageElement.data 'image'  #todo: refactor?
    @imageCookie.add imageId
    @showImageInDropbox imageId,imageMeta
    el.hide()
  ###
  
  ###
  showInfo: (meta) ->
    $("#info .name span").text meta.title
    $("#info .author span").text meta.artist
    $("#info .year span").text meta.year
  
  showTags: (meta) ->
    #todo
    
  showInfoTag: (type) ->
    $("#infoTags").show() if not $("#infoTags").is(':visible')
    target = $("##{type}")
    if target.is(":visible") 
      target.hide() 
    else
      meta = $("#slideshow .img:visible:first").data 'image'
      @showTags meta if type is 'tagging'
      @showInfo meta if type is 'info'
      target.show()  
    
  '.footer .info click': ->
    @showInfoTag 'info'
  
  '.footer .tag click': ->
    @showInfoTag 'tagging'
  


  #todo?
  showSingleSlide: (imageId) ->
    @model.getImage imageId, {}, (image) =>
      @displayScreen 'slideshow', @view('slideshow', { images: [image] })
      @showSlide 0

  showSlide: (index) ->
    totalCount = $("#slideshow .img").length
    index = 0 if index is totalCount
    index = (totalCount-1) if index is -1

    $("#slideshow .img").hide()

    imageElement = $("#slideshow .img:eq(#{index})")
    imageElement.show()

    imageId = imageElement.data 'id'
    imageMeta = imageElement.data 'image'

    $("h1").text imageMeta.title
    @showInfo imageMeta

    if totalCount is 1 then $(".counter,.prev,.next").hide() else $(".counter").text "#{index+1}/#{totalCount}"
    # todo: look at add buttons etc
    # if @imageCookie.contains imageId then $('.add').hide() else $('.add').show()
    
  '#slideshow .add click': (el) ->
    @addImageToDropbox el.parent()
  ###