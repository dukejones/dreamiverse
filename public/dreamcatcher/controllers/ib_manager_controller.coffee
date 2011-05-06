$.Controller 'Dreamcatcher.Controllers.IbManager',

  model: Dreamcatcher.Models.ImageBank
  
  init: ->
    @populateLists()
    @createUploader()
    images = @getImages()
    @model.getImage image,{},@callback('showImage') for image in images
  
  ##cookies
  getImages: ->
    return $.cookie("selectedImages").split(",") if $.cookie("selectedImages")?
  
  addImage: (imageId) ->
    images = @getImages()
    if images.indexOf(imageId) is -1
      images.push(imageId)
      $.cookie("selectedImages",images.join(","))
  
  removeImage: (imageId) ->
    images = @getImages()
    newImages = images.filter (item) ->
      return item isnt imageId.toString()
    $.cookie("selectedImages",newImages.join(","))
      
  showImage: (image) ->
    $(".imagelist").append(@view('show',image))
    
  populateLists: ->
    $("#type select").append("<option>#{type}</option>") for type in @model.types
    $("#category select").append("<option>#{category.name}</option>") for category in @model.categories
  
  isText: (attr) ->
    return $("##{attr} input[type='text']").exists()

  isSelect: (attr) ->
    return $("##{attr} select").exists()

  getAttribute: (attr,selectedOnly) ->
    return null if not $("##{attr} input[type='checkbox']").attr("checked") and selectedOnly

    if @isText(attr)
      return $("##{attr} input[type='text']").val()
    else if @isSelect(attr)
      return $("##{attr} select option:selected").val()
    else
      log $("##{attr} textarea").val()
      return $("##{attr} textarea").val()
  
  setAttribute: (attr, value) ->
    $("##{attr} input[type='checkbox']").attr("checked",value? and value isnt "*")
    if @isText(attr)
      if value is "*"
        $("##{attr} input[type='text']").val("").attr("placeholder","different")
      else
        $("##{attr} input[type='text']").val(value).removeAttr("placeholder")
    else if @isSelect(attr)
      $("##{attr} select").val(value)
    else
      $("##{attr} textarea").val(value)
  
  grabMetaData: () ->
    selectedOnly = true
    image = {}
    for attribute in @model.attributes
      value = @getAttribute(attribute,selectedOnly)
      image[attribute] = value if value? or not selectedOnly
    log image
    return {image: image}
    
  displayMetaData: (image) ->
    @setAttribute(attribute,image[attribute]) for attribute in @model.attributes
    
  showCommonMeta: ->
    common = {}
    $(".imagelist li.selected").each (index, element) =>
      data = $(element).data 'image'
      for attr in @model.attributes
        if not common[attr]?
          common[attr] = data[attr]
        else if common[attr] isnt data[attr]
          common[attr] = '*'
    @displayMetaData(common)
    
  createUploader: ->
    uploader = new qq.FileUploader {
      element: $('#uploader').get(0)
      action: '/images.json'
      maxConnections: 1
      params: {
        image: {
          type: "Bedsheet"
        }
      }
      debug: true
      onSubmit: (id, fileName) ->
        log id+' '+fileName
      onComplete: (id, fileName, result) =>
        image_url = result.image_url
        log image_url
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
      @displayMetaData el.data('image')
    
    @showCommonMeta()
    
  '.all click': (el) ->
    if el.text().indexOf('all') != -1
      $(".imagelist li").addClass('selected')
      el.text('select none')
    else
      $(".imagelist li").removeClass('selected')
      el.text('select all')
      
    @showCommonMeta()
  
  '.save click': (el) ->
    $('.imagelist li.selected').each (index,element) =>
      imageId = $(element).data('id')
      @model.update imageId,@grabMetaData()
      @model.getImage imageId,{},@callback('updateImageMeta',$(element))
      
  updateImageMeta: (el,data) ->
    el.data('image',data)
  
  ###  
  checkDifferent: (el) ->
    if el.is(':checked') and $("input[type='text']",el.parent()).attr("placeholder") is "different"
      if not confirm 'are you sure?'
        el.attr("checked",false)
        return false
    return true
    
  'input[type="checkbox"] checked': (el) ->
    @checkDifferent(el)
  ###
     
  'input[type="text"],select focus': (el) ->
    $("input[type='checkbox']",el.parent()).attr("checked",true)
    
  'input[type="text"] blur': (el) ->
    $("input[type='checkbox']",el.parent()).attr("checked",el.val().length > 0)
        
      
  '.cancel click': (el) ->
    $('.imagelist li.selected').each (index,element) =>
      imageId = $(element).data('id')
      @model.disable imageId,{},@callback('disable',$(element),imageId)
  
  disable: (el, id) ->
    el.css("opacity",0.5)
    @removeImage id
  
  
