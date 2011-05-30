$.Class 'Dreamcatcher.Classes.UploadHelper', {  

  createUploader: (attr, submit, complete, cancel, progress) ->
    return new qq.FileUploader {
      
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
      
      element: $(attr.elementId).get(0)
      action: attr.url
      template: $(attr.elementId).html()
      fileTemplate: attr.fileTemplate
      
      onSubmit: submit
      onComplete: complete
      onCancel: cancel
      onProgress: progress
    }

}, {}

