$.Class 'Dreamcatcher.Classes.UploadHelper', {  

  createUploader: (attr, submit, complete, cancel, progress) ->
    return new qq.FileUploader {
      
      maxConnections: 1
      params: {}
      debug: false # todo: false
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif']

      classes: {
        button: if attr.button? then attr.button else 'browse'
        drop: if attr.drop? then attr.drop else 'dropArea'
        dropActive: 'active'
        list: if attr.list then attr.list else 'imagelist'
        progress: 'progress'
        file: 'file'
        spinner: 'spinner'
        size: 'size'
        cancel: 'cancel'
        success: 'success'
        fail: 'fail'
      }
      
      element: attr.element.get(0)
      action: attr.url
      template: attr.element.html()
      fileTemplate: $.View('//dreamcatcher/views/image_upload.ejs')
      
      onSubmit: submit
      onComplete: complete
      onCancel: cancel
      onProgress: progress
    }

}, {}

