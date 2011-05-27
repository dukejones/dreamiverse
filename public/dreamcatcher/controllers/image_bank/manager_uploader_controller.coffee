$.Controller 'Dreamcatcher.Controllers.ImageBank.ManagerUploader',

  getView: (url, data) ->
    return @view "//dreamcatcher/views/image_bank/manager/#{url}.ejs", data

  init: ->
    params = {
      elementId: '#uploader'
      url: '/images.json'
      fileTemplate: @getView 'image_upload'
    }
    @fileUploader = Dreamcatcher.Classes.UploadHelper.createUploader params, @callback('uploadSubmit'), @callback('uploadComplete'), @callback('uploadCancel'), @callback('uploadProgress')


  '#uploader .browse click': (el) ->
    @fileUploader.setParams @manager.getMeta 'organization' if not @replaceImageId?

  uploadSubmit: (id, fileName) ->
    $('#upload input[type=file]').attr 'multiple', 'multiple'
    @fileUploader.setParams @manager.getMeta 'organization' if not @replaceImageId?
  
  uploadComplete: (id, fileName, result) ->
    if result? and result.image?
      @manager.showImage result.image, @getUploadElement fileName
    else
      log 'error'

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
    progressEl = $('progress-bar',uploadEl)
    progressEl.css('width',"#{percent}%")
  
  
  getUploadElement: (fileName) ->
    return $("#imagelist li .file:contains('#{fileName}')").closest 'li'
    
  '#imagelist .replace click': (el) ->
    @replaceImageId = el.parent().data 'id'
    @fileUploader.setParams { id: @replaceImageId }
    fileInput = $('#uploader .browse input[type=file]')
    fileInput.removeAttr 'multiple'
    fileInput.click()