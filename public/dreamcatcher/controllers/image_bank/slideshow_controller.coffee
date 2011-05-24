$.Controller 'Dreamcatcher.Controllers.ImageBank.Slideshow',

  model: Dreamcatcher.Models.Image
  
  init: ->
    $(document).keyup (event) ->
      switch event.keyCode
        when 27 then $('.close').click()
        when 37 then $('.gradient-left').click()
        when 39 then $('.gradient-right').click()
                
  show: (images, currentIndex) ->
    @images = images
    
    html = $('#gallery').html()
    $('#gallery').html ''
    $('#gallery').css 'width', (images.length * 720) + 'px'
    
    for image in images
      $('#gallery').append html 
      @setImage '#gallery .imageContainer:last', image
        
    @currentIndex = if currentIndex? then currentIndex else 0
    
    $('.commentsPanel').hide()
    
    $('#slideshow-back').show()
    $('#slideshow-back').height "1000px"
    
    
  showImage: (parent, image) ->
    $('img', parent).attr 'src', @getOriginal image 
    $('.info .name span', parent).text image.title
    $('.info .author span', parent).text image.artist
    $('.info .year span', parent).text image.year
    $('.tagInput input', parent).text image.tags
    
  '.close click': (el) ->
    $('#slideshow-back').hide()
    $('#frame.browser').show()
    
  changeSlide: (difference) ->
    @index += difference
    $('#gallery').animate {
      left: (index * 720) + 'px'
    }
  
  getOriginal: (image) ->
    return "/images/uploads/originals/#{image.id}.#{image.format}"
  
  '.gradient-left click': (el) ->
    @changeSlide -1
      
  '.gradient-right click': (el) ->
    @changeSlide 1

  '.controls .info click': (el) ->
    $('#gallery .info').toggle()
  
  '.controls .tagging click': (el) ->
    $('#gallery .tagging').toggle()

  '.controls .download click': (el) ->
    window.location.href = @getOriginal @images[@index]
  
  '.controls .comment click': (el) ->
    $('.controls .commentsPanel').toggle()
