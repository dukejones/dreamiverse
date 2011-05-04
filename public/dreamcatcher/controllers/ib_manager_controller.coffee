$.Controller 'Dreamcatcher.Controllers.IbManager',
  init: ->
    @createUploader()
    
  createUploader: ->
    uploader = new qq.FileUploader {
      element: $('#uploader').get(0)
      action: '/images.json'
      maxConnections: 1
      params: { image: {
        category: 'Bedsheets'
        genre: 'Paintings'
        section: 'Library'
      } }
      debug: true
      onSubmit: (id, fileName) ->
        log id+' '+fileName
      onComplete: (id, fileName, responseJSON) ->
        alert 'completed'
      template: @view('template')
      fileTemplate: @view('fileTemplate')
      classes: {
        button: 'browse'
        drop: 'drag'
        dropActive: 'dropbox'
        list: 'imagelist'
        
        progress: 'progress-meter'
        file: 'upload-file'
        spinner: 'upload-spinner'
        size: 'upload-size'
        cancel: 'upload-cancel'
        success: 'upload-success'
        
        fail: 'upload-fail'
      }
    }
