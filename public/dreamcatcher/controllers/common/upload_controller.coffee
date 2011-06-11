$.Controller.extend 'Dreamcatcher.Controllers.Common.Upload', {
  pluginName: 'uploader'
},{

  init: (element, customOptions) ->
    @element = $(element)
    @load customOptions if customOptions?

  load: (customOptions) ->
    @filesUploaded = 0

    if customOptions and customOptions.singleFile?
      @singleFile = customOptions.singleFile 
      delete customOptions.singleFile

    options = {  
      maxConnections: 1
      params: {}
      debug: true # todo: false
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif']

      classes: {
        button: 'browse'
        drop: 'dropArea'
        dropActive: 'active'
        list: 'imagelist'
        progress: 'progress'
        file: 'file'
        spinner: 'spinner'
        size: 'size'
        cancel: 'cancel'
        success: 'success'
        fail: 'fail'
      }

      element: @element.get(0)
      action: '/images.json'
      template: @element.html()
      fileTemplate: $.View('//dreamcatcher/views/images/image_upload.ejs', {singleFile: @singleFile})

      onSubmit: (id, fileName) =>
        log id

      onComplete: (id, fileName, result) =>
        if result.image?
          @getUploadElement(fileName).replaceWith $.View('//dreamcatcher/views/images/manager/image_show.ejs', result.image)
          @filesUploaded++

        filesRemaining = $('li.uploading:not(.fail)', @element).length
        filesFailed = $('li.uploading.fail', @element).length
        if filesRemaining is 0
          message = "#{@filesUploaded} images have been uploaded"
          message += " (#{filesFailed} failed)" if filesFailed > 0
          notice message
          @filesUploaded = 0

      onCancel: (id, fileName) =>
        uploadEl = @getUploadElement fileName
        uploadEl.remove()

      onProgress: (id, fileName, loaded, total) =>
        uploadEl = @getUploadElement fileName
        uploadEl.show()

        if @replaceImageId? and fileName?
          imageEl = @getImageElement @replaceImageId
          imageEl.replaceWith @getUploadElement fileName
          @clearReplaceImage()

        percent = loaded / total * 100
        progressEl = $('.progress-bar', uploadEl)
        progressEl.animate {
          width: "#{percent}%"
        }, 'fast'
    }

    #extend existing options
    if customOptions?
      #need to extract the custom classes out, so that the 'classes' varible is not overridden completely.
      customClasses = customOptions.classes
      delete customOptions.classes
      $.extend options, customOptions
      $.extend options.classes, customClasses

    @uploader = new qq.FileUploader options
    $('input[type=file]', el).removeAttr 'multiple' if @singleFile

  getUploadElement: (fileName) ->
    return $("li .file:contains('#{fileName}')", @element).closest 'li'
    
  getImageElement: (imageId) ->
    return $("li[data-id=#{imageId}]", @element)

  clearReplaceImage: ->
    @replaceImageId = null
    $('input[type=file]', @element).attr 'multiple', 'multiple' if not @singleOnly
    #$('#imagelist').removeClass 'imageReplace'

  setReplaceImage: (imageId) ->
    @replaceImageId = imageId
    @uploader.setParams { id: @replaceImageId }
    #$('#imagelist').addClass 'imageReplace'

    fileInput = $('input[type=file]', @element)
    fileInput.removeAttr 'multiple'
    fileInput.click()
    
  setParams: (params) ->
    @uploader.setParams params

  '.replace click': (el) ->
    @setReplaceImage el.parent().data 'id'

}

    