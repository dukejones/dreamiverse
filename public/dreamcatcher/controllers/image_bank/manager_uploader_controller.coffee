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
    @clearReplaceImage()
  
  getImageElement: (imageId) ->
    return $("#imagelist li[data-id=#{imageId}]")

  uploadSubmit: (id, fileName) ->
    @clearReplaceImage fileName
  
  uploadComplete: (id, fileName, result) ->
    if result? and result.image?
      @showImage result.image, @getUploadElement fileName
      if @isDropbox() #todo: test
        el = @getImageElement result.image.id
        @parent.addImageToDropbox result.image.id
    else
      log 'error'

  uploadCancel: (id, fileName) ->
    el = @getUploadElement fileName
    el.remove()

  uploadProgress: (id, fileName, loaded, total) ->
    log loaded
    log total
  
  clearReplaceImage: (fileName)->
    @fileUploader.setParams @manager.getMeta 'organization'
    $('#upload input[type=file]').attr 'multiple', 'multiple'
    
    if @replaceImageId? and fileName?
      el = @getImageElement @replaceImageId
      el.replaceWith @getUploadElement fileName
      @replaceImageId = null
  
  setReplaceImage: (imageId) ->
    @replaceImageId = imageId
    @fileUploader.setParams { id: @replaceImageId }
    fileInput = $('#uploader .browse input[type=file]')
    fileInput.removeAttr 'multiple'
    fileInput.click()

  getUploadElement: (fileName) ->
    return $("#imagelist li .file:contains('#{fileName}')").closest 'li'
    
  '#imagelist .replace click': (el) ->
    @setReplaceImage el.parent().data 'id'