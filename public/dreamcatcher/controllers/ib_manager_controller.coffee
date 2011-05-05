$.Controller 'Dreamcatcher.Controllers.IbManager',
  init: ->
    $.cookie("selectedImages",2868)
    @createUploader()
    imageId = @getSelectedImages()[0]
    Dreamcatcher.Models.ImageBank.getImage imageId,{},@callback('showImage')
    
  getSelectedImages: ->
    return $.cookie("selectedImages").split(",") if $.cookie("selectedImages")?
    #return 2868
  
  addSelectedImage: (imageId) ->
    images = @getSelectedImages()
    #if not $.inArray(imageId.toString(),images)
    #if images.length > 0
    #$.cookie("selectedImages")
  
  showImage: (image) ->
    @showMetaData image
    #$(".imagelist ul").append 'x'
    $(".imagelist").append(@view('show',image))
    
  metaData: ->
    image: {
      #todo: include checkbox if
      category: $("#image_category select").val()
      genre: $("#image_genre select").val()
      section: $("#image_section select").val()
      #info
      title: $("#image_title input[type='text']").val()
      album: $("#image_album input[type='text']").val()
      artist: $("#image_author input[type='text']").val() #diff
      location: $("#image_location input[type='text']").val()
      year: $("#image_year input[type='text']").val()
      notes: $("#image_notes input[type='text']").val()
    }
    
  showMetaData: (image) ->
      #todo: include checkbox if
      $("#image_category select").val(image.category)
      $("#image_genre select").val(image.genre)
      $("#image_section select").val(image.section)
      #info
      $("#image_title input[type='text']").val(image.title)
      $("#image_album input[type='text']").val(image.album)
      $("#image_author input[type='text']").val(image.artist) #diff
      $("#image_location input[type='text']").val(image.location)
      $("#image_year input[type='text']").val(image.year)
      $("#image_notes input[type='text']").val(image.notes)
    
    
  createUploader: ->
    uploader = new qq.FileUploader {
      element: $('#uploader').get(0)
      action: '/images.json'
      maxConnections: 1
      params: @metaData()
      debug: true
      onSubmit: (id, fileName) ->
        log id+' '+fileName
      onComplete: (id, fileName, result) ->
        image_url = result.image_url
        image = result.image

        $(".imagelist li:eq(#{id})").data("id",image.id).html("<img src='#{image_url}'/>")
        
      template: @view('template')
      fileTemplate: @view('fileTemplate')
      classes: {
        button: 'browse'
        drop: 'dropArea'
        dropActive: 'dropAreaActive'
        list: 'imagelist'
        
        progress: 'progress-meter'
        file: 'upload-file'
        spinner: 'spinner'
        size: 'upload-size'
        cancel: 'upload-cancel'
        success: 'upload-success'
        
        fail: 'upload-fail'
      }
    }
  
  '.imagelist li click': (el) ->
    if el.hasClass('selected')
      el.removeClass('selected')
    else
      el.addClass('selected')
      @addSelectedImage el.data('id')
    
  '.save click': (el) ->
    $('.imagelist li.selected').each (index,element) =>
      imageId = $(element).data('id')
      Dreamcatcher.Models.ImageBank.update imageId,@metaData(),->
        alert 'updated'
