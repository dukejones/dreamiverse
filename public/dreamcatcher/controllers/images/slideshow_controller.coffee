$.Controller 'Dreamcatcher.Controllers.ImageBank.Slideshow',

  model: Dreamcatcher.Models.Image

  init: ->
    $(document).keyup (event) ->
      switch event.keyCode
        when 27 then $('.close').click()
        when 37 then $('.gradient-left').click()
        when 39 then $('.gradient-right').click()
                
  show: (images, imageId) ->
    if not @template?
      @template = $('#gallery').html()
    $('#gallery').html ''
    $('#gallery').css 'width', (images.length * 820 + 280) + 'px'
    
    for image in images
      $('#gallery').append @template
      @showImage '#gallery .imageContainer:last', image
    
    @images = images
    @index = 0
    for i in [0..@images.length-1]
      @index = i if @images[i].id is imageId
    
    @changeSlide 0
    
    $('.comment,.commentTarget,.commentsPanel').hide() #hide for now
    $('#slideshow-back').fadeIn 'slow'
    $('#slideshow-back').height "1000px" #todo
    
  close: ->
    $('#slideshow-back').fadeOut()
    @parent.showBrowser()
    
  showImage: (parent, image) ->
    $('img', parent).attr 'src', @getLarge image 
    $('.info .name span', parent).text image.title
    $('.info .author span', parent).text image.artist
    $('.info .year span', parent).text image.year
    $('.newTag', parent).val image.tags
    $(parent).data 'id', image.id
    
  '.close click': (el) ->
    @close()
    
  getCurrent: ->
    $("#gallery .imageContainer:eq(#{@index})")
  
  changeSlide: (difference) ->
    if @index + difference is -1
      return
    
    if @index + difference is @images.length
      @close()
          
    @index += difference
    $('.gradient-left').toggle @index isnt 0
    
    if @index is @images.length - 1 
      $('.gradient-right .text').text 'close slideshow'
      $('.gradient-right span').text 'x'
    else
      $('.gradient-right .text').text 'right arrow key'
      $('.gradient-right span').html '&rsaquo;'
    
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
    info = $('#gallery .info')
    info.toggle()
    if info.is ':visible'
      $('#gallery .tagging').hide()
  
  '.controls .tagging click': (el) ->
    tagging = $('#gallery .tagging')
    tagging.toggle()
    if tagging.is ':visible'
      $('#gallery .info').hide()
    
  '#gallery .tagAdd click': (el) ->
    imageId = el.closest('.imageContainer').data 'id'
    tags = $('.newTag', el.parent()).val()
    
    image = { tags: tags }
    @model.update imageId, { image: image }

  '.controls .download click': (el) ->
    window.open @getOriginal @images[@index]
    

