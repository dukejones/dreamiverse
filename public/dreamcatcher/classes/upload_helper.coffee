$.Class 'Dreamcatcher.Classes.UploadHelper', {  

  #- cancel & progress are optional arguments
  create: (el, singleOnly, customOptions, submit, complete, cancel, progress) ->
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
      
      element: el.get(0)
      action: '/images.json'
      template: el.html()
      fileTemplate: $.View('//dreamcatcher/views/images/image_upload.ejs')
      
      onSubmit: submit
      onComplete: complete
    }
    
    #extend existing options (without overridding classes completely)
    customClasses = customOptions.classes
    delete customOptions.classes
    $.extend options, customOptions
    $.extend options.classes, customClasses
    options.onProgress = progress if progress?
    options.onCancel = cancel if cancel?
    
    log options
    
    uploader = new qq.FileUploader options
    $('input[type=file]', el).removeAttr 'multiple' if singleOnly
    return uploader

}, {}

