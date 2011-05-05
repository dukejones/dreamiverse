$.Controller 'Dreamcatcher.Controllers.IbManager',
  init: ->
    @createUploader()
    images = @getImages()
    Dreamcatcher.Models.ImageBank.getImage image,{},@callback('showImage') for image in images
    
  getImages: ->
    return $.cookie("selectedImages").split(",") if $.cookie("selectedImages")?
  
  addImage: (imageId) ->
    images = @getImages()
    #if not $.inArray(imageId.toString(),images)
    images.push(imageId)
    $.cookie("selectedImages",images.join(","))
      
  showImage: (image) ->
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
    $("#category select").val(image.category)
    $("#genre select").val(image.genre)
    $("#section select").val(image.section)
    #info
    $("#title input[type='text']").val(image.title)
    $("#album input[type='text']").val(image.album)
    #$("#author input[type='text']").val(image.artist) #diff
    $("#location input[type='text']").val(image.location)
    $("#year input[type='text']").val(image.year)
    $("#notes input[type='text']").val(image.notes)
    
  createUploader: ->
    uploader = new qq.FileUploader {
      element: $('#uploader').get(0)
      action: '/images.json'
      maxConnections: 1
      params: @metaData()
      debug: true
      onSubmit: (id, fileName) ->
        log id+' '+fileName
      onComplete: (id, fileName, result) =>
        image_url = result.image_url
        image = result.image
        $(".imagelist li:last").data("id",image.id).data("image",JSON.stringify(image)).html("<img src='#{image_url}'/>")
        @addImage image.id
      template: $("#uploader").html()
      fileTemplate: @view('fileTemplate')
      classes: {
        button: 'browse'
        drop: 'dropArea'
        dropActive: 'active'
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
      @showMetaData el.data('image')#eval("(#{})")
    
  '.save click': (el) ->
    imageData = @metaData()
    $('.imagelist li.selected').each (index,element) =>
      imageId = $(element).data('id')
      $(element).data 'image',imageData
      Dreamcatcher.Models.ImageBank.update imageId,imageData
