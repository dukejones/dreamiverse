$.Controller 'Dreamcatcher.Controllers.IbSlideshow',

  model: Dreamcatcher.Models.ImageBank
  
  init: ->
    $(document).keyup (event) ->
      switch event.keyCode
        when 27 then $('.close').click()
        when 37 then $('.gradient-left').click()
        when 39 then $('.gradient-right').click()
                
  show: (images, currentIndex) ->
    html = $('#gallery').html()
    $('#gallery').html ''
    $('#gallery').css 'width', (images.length * 720 + 20)+'px'
    for image in images
      $('#gallery').append html 
      @setImage '#gallery .imageContainer:last', image
        
    @images = images
    @currentIndex = if currentIndex? then currentIndex else 0
    $('.commentsPanel').hide()
    $('#slideshow-back').show()
    $('#slideshow-back').height "1000px"
    
    
  setImage: (parentSelector, image) ->
    $('img', parentSelector).attr 'src', "/images/uploads/originals/#{image.id}.#{image.format}"
    $('.info .name span', parentSelector).text image.title
    $('.info .author span', parentSelector).text image.artist
    $('.info .year span', parentSelector).text image.year
    $('.tagInput input', parentSelector).text image.tags
    
  '.close click': (el) ->
    $('#slideshow-back').hide()
    $('#frame.browser').show()
    
  '.gradient-left click': (el) ->
    left = parseInt $('#gallery').css('left').replace('px')
    $('#gallery').animate {
      left: (left+720)+'px'
    }
      
  '.gradient-right click': (el) ->
    
    left = parseInt $('#gallery').css('left').replace('px')
    $('#gallery').animate {
      left: (left-720)+'px'
    }

  '.controls .info click': (el) ->
    $('#gallery .info').toggle()
  
  '.controls .tagging click': (el) ->
    $('#gallery .tagging').toggle()

  '.controls .download click': (el) ->
    alert 
  
  '.controls .comment click': (el) ->
    $('.controls .commentsPanel').show()
