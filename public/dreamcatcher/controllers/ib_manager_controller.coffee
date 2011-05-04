$.Controller 'Dreamcatcher.Controllers.IbManager',
  
  init: ->
    @createUploader()
    
  createUploader: ->            
    uploader = new qq.FileUploader {
      element: document.getElementById('dropbox')
      action: '/images.json'
      maxConnections: 1
      #params: imageMetaParams
      debug: true
      onSubmit: (id, fileName) ->
        alert id+'s'+fileName
        collectParams() # Grab the variables from the UI for the params
      onComplete: (id, fileName, responseJSON) ->
        alert 'completed'
    }        
