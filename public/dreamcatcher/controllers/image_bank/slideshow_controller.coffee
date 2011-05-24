$.Controller 'Dreamcatcher.Controllers.ImageBank.Slideshow',

  init: ->
    $(document).keyup (event) ->
      switch event.keyCode
        when 27 then $('.close').click()
        when 37 then $('.gradient-left').click()
        when 39 then $('.gradient-right').click()
                
  show: (images, index) ->    
    html = $('#gallery').html()
    $('#gallery').html ''
    $('#gallery').css 'width', (images.length * 720) + 'px'
    
    for image in images
      $('#gallery').append html 
      @showImage '#gallery .imageContainer:last', image
      $("#gallery .imageContainer").css "opacity", 0.3
    
    @images = images      
    @index = if index? then index else 0
    @changeSlide 0
    
    $('.commentsPanel').hide()
    $('#slideshow-back').show()
    $('#slideshow-back').height "1000px"
    
    
  showImage: (parent, image) ->
    $('img', parent).attr 'src', @getLarge image 
    $('.info .name span', parent).text image.title
    $('.info .author span', parent).text image.artist
    $('.info .year span', parent).text image.year
    $('.tagInput input', parent).text image.tags
    
  '.close click': (el) ->
    $('#slideshow-back').hide()
    $('#frame.browser').show()
    
  fadeCurrent: ->
    current = $("#gallery .imageContainer:eq(#{@index})")
    if parseInt(current.css('opacity')) is 1
      #current.fadeTo 500, 0.5
      current.css 'opacity', 0.3
      current.removeClass 'current'
    else
      current.css 'opacity', 1
      current.addClass 'current'
    
  changeSlide: (difference) ->
    if @index + difference is -1
      return
    if @index + difference is @images.length
      $('#slideshow-back').fadeOut 'fast'
      $('#frame.browser').show()
    
    @fadeCurrent()
    @index += difference
    $('#gallery').animate {
      left: (@index * -720 + 220) + 'px'
    }, 'fast'
    @fadeCurrent()
    
  getOriginal: (image) ->
    return "/images/uploads/originals/#{image.id}.#{image.format}"
    
  getLarge: (image) ->
    return "/images/uploads/#{image.id}-medium.#{image.format}"
  
  '.gradient-left click': (el) ->
    @changeSlide -1
      
  '.gradient-right click': (el) ->
    @changeSlide 1

  '.controls .info click': (el) ->
    $('#gallery .info').toggle()
  
  '.controls .tagging click': (el) ->
    $('#gallery .tagging').toggle()

  '.controls .download click': (el) ->
    window.open @getOriginal @images[@index]
  
  '.controls .comment click': (el) ->
    $('.controls .commentsPanel').toggle()
