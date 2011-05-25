$.Controller 'Dreamcatcher.Controllers.ImageBank.Slideshow',

  init: ->
    $(document).keyup (event) ->
      switch event.keyCode
        when 27 then $('.close').click()
        when 37 then $('.gradient-left').click()
        when 39 then $('.gradient-right').click()
                
  show: (images, index) ->
    if not @template?
      @template = $('#gallery').html()
    $('#gallery').html ''
    $('#gallery').css 'width', (images.length * 820 + 280) + 'px'
    
    for image in images
      $('#gallery').append @template
      @showImage '#gallery .imageContainer:last', image
    
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
    
  getCurrent: ->
    $("#gallery .imageContainer:eq(#{@index})")
  
  changeSlide: (difference) ->
    if @index + difference is -1
      return
    
    if @index + difference is @images.length
      $('#slideshow-back').fadeOut 'fast'
      $('#frame.browser').show()
          
    @index += difference
    
    $('.gradient-left').toggle @index isnt 0
    
    rightText = if @index is @images.length - 1 then 'close slideshow' else 'right arrow key'
    $('.gradient-right .text').text rightText
    
    $('#gallery').animate {
      left: (@index * -820 + 280) + 'px'
    }, 'fast'
    
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
    
  '#gallery .tagAdd click': (el) ->
    alert $("newTag",el.parent).val()

  '.controls .download click': (el) ->
    window.open @getOriginal @images[@index]
    

