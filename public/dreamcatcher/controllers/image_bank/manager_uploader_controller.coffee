$.Controller 'Dreamcatcher.Controllers.ImageBank.ManagerUploader',

  getView: (url, data) ->
    return @view "//dreamcatcher/views/image_bank/manager/#{url}.ejs", data

  init: ->
    @filesUploaded = 0
    
    @fileUploader = Dreamcatcher.Classes.UploadHelper.createUploader {
      elementId: '#uploader'
      url: '/images.json'
      fileTemplate: @getView 'image_upload'
    }, @callback('uploadSubmit'), @callback('uploadComplete'), @callback('uploadCancel'), @callback('uploadProgress')
  
  setDefaultUploadParams: ->
    @fileUploader.setParams @manager.getMeta 'organization' if not @replaceImageId?
    
  clearReplaceImage: ->
    if @replaceImageId?  
      @replaceImageId = null
      @setDefaultUploadParams()
      
    $('#upload input[type=file]').attr 'multiple', 'multiple'  
    $('#imagelist').removeClass 'imageReplace'
    
  setReplaceImage: (imageId )->
    @replaceImageId = imageId
    @fileUploader.setParams { id: @replaceImageId }
    $('#imagelist').addClass 'imageReplace'
    
    fileInput = $('#uploader .browse input[type=file]')
    fileInput.removeAttr 'multiple'
    fileInput.click()
    
  getUploadElement: (fileName) ->
    return $("#imagelist li .file:contains('#{fileName}')").closest 'li'
    
  uploadSubmit: (id, fileName) ->
    @setDefaultUploadParams()  
  
  uploadComplete: (id, fileName, result) ->
    if result.image?
      @manager.showImage result.image, @getUploadElement fileName
      @filesUploaded++
      
    @clearReplaceImage()
    filesRemaining = $('#imagelist .uploading:not(.fail)').length
    filesFailed = $('#imagelist .uploading.fail').length
    if filesRemaining is 0
      message = "#{@filesUploaded} images have been uploaded"
      message += " (#{filesFailed} failed)" if filesFailed > 0
      notice message
      @filesUploaded = 0


  uploadCancel: (id, fileName) ->
    el = @getUploadElement fileName
    el.remove()

  uploadProgress: (id, fileName, loaded, total) ->
    uploadEl = @getUploadElement fileName
    uploadEl.show()
    if @replaceImageId? and fileName?
      imageEl = @manager.getImageElement @replaceImageId
      imageEl.replaceWith @getUploadElement fileName
      @replaceImageId = null
    
    percent = loaded / total * 100
    progressEl = $('.progress-bar',uploadEl)
    progressEl.animate {
      width: "#{percent}%"
    }, 'fast'

    
  '#imagelist .replace click': (el) ->
    @setReplaceImage el.parent().data 'id'
