$.Controller 'Dreamcatcher.Controllers.IbManager',

  model: Dreamcatcher.Models.ImageBank
  
  init: ->
    @imageCookie = new Dreamcatcher.Classes.CookieHelper("imagebank")
    @populateLists()
    @createUploader()
    @loadImages @imageCookie.getAll()
  
  populateLists: ->
    $("#type select").append("<option>#{type}</option>") for type in @model.types
    for category in @model.categories
      $("#category select").append("<option>#{category.name}</option>")
      $("#category select option:last").data("genres",category.genres)


  # UPLOADER

  createUploader: ->
    @uploader = new qq.FileUploader {
      element: $('#uploader').get(0)
      action: '/images.json'
      maxConnections: 1
      params: {
        image: {
          type: "Library"
          category: "Classical Art"
          genre: "Africa"
        }
      }
      debug: true
      onSubmit: (id, fileName) ->
        #log id+' '+fileName
      onComplete: (id, fileName, result) =>
        image_url = result.image_url
        image = result.image
        @showImage $("#imagelist li .file:contains('#{fileName}')").closest('li'),image
      template: $("#uploader").html()
      fileTemplate: @view('fileTemplate')
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
    }


  loadImages: (images) ->
    log images
    if images?
      @model.getImage image,{},@callback('showImage',null) for image in images
    
  showImage: (uploadElement, image) ->
    imageHtml = @view 'show',image
    if uploadElement?
      uploadElement.replaceWith imageHtml
    else
      $("#imagelist").append imageHtml
  
  # IMAGE META
    
  showCommonImageMetaData: ->
    common = {}
    $("#imagelist li.selected").each (index, element) =>
      data = $(element).data 'image'
      
      #- special cases
      data.date = $.format.date(data["created_at"].replace("T"," "), 'MMM dd, yyyy')
      data.user = "phong"
      
      for attr in @model.attributes
        if not common[attr]?
          common[attr] = data[attr]
        else if common[attr] isnt data[attr]
          common[attr] = '*'
    @displayMetaData(common)

  displayMetaData: (image) ->
    @setAttribute(attribute,image[attribute]) for attribute in @model.attributes
  
  isText: (attr) ->
    return $("##{attr} input[type='text']").exists()

  isSelect: (attr) ->
    return $("##{attr} select").exists()
  
  setAttribute: (attr, value) ->
    $("##{attr} input[type='checkbox']").attr("checked",value? and value isnt "*")
    if @isText(attr)
      if value is "*"
        $("##{attr} input[type='text']").val("").attr("placeholder","different")
      else
        $("##{attr} input[type='text']").val(value).removeAttr("placeholder")
    else if @isSelect(attr)
      $("##{attr} select").val(value).change()
    else
      $("##{attr} textarea").val(value)

  
  # DOM EVENTS
  
  #- select all/select none
  '.all click': (el) ->
    if el.text().indexOf('all') != -1
      $("#imagelist li").addClass('selected')
      el.text('select none')
    else
      $("#imagelist li").removeClass('selected')
      el.text('select all')
    @showCommonImageMetaData()
    
  #- select individual images
  '#imagelist li click': (el) ->
    if el.hasClass('selected')
      el.removeClass('selected')
    else
      el.addClass('selected')
      #@displayMetaData el.data('image')
    @showCommonImageMetaData()
    
  #- delete individual image
  '.close click': (el) ->
    if el.parent().css('opacity') is '0.5'
      imageId = el.parent().data('id')
      el.parent().hide()
    else
      el.parent().css('opacity',0.5)


  #- input (select) change
  '#category select change': (el) ->
    genres = $("option:selected",el).data("genres")
    $("#genre select").html("")
    $("#genre select").append("<option>#{genre}</option>") for genre in genres

  #- input (select, text) focus
  'input[type="text"],select focus': (el) ->
    $("input[type='checkbox']",el.parent()).attr("checked",true)

  #- input (select, text) blur - update Meta
  'input[type="text"],textarea,select blur': (el) ->
    value = el.val().trim()
    doUpdate = value.length > 0
    $("input[type='checkbox']",el.parent()).attr("checked",doUpdate)
    return if not doUpdate
    attribute = el.parent().attr('id')
    $('#imagelist li.selected').each (index,element) =>
      meta = $(element).data 'image'
      meta[attribute] = value
      $(element).data 'image',meta


  #- resets all data to original
  '.reset click': (el) ->
    $("#imagelist li").removeClass("selected")
    @displayMetaData {}
    $('#imagelist li').each (index,element) =>
      imageId = $(element).data 'id'
      @model.getImage imageId,{},(data) =>
        $(element).data('image',data)
      $(element).show()
      
  #- saves all data and goes back to ib_browser
  '.save click': (el) ->
    @imageCookie.clear()
    $('#imagelist li').each (index,element) =>
      imageId = $(element).data('id')
      if $(element).is(":visible")
        data = $(element).data 'image'
        delete data.date
        delete data.user
        data.section = "Library"
        @model.update imageId,{image: data},=>
          @imageCookie.add image.id
      else
        @model.disable imageId,{},=>
          @imageCookie.remove imageId
        
    #window.location.href = "/images"  

  #- cancels all data changes and goes back to ib_browser
  '.cancel click': (el) ->
    $('#imagelist li.selected').each (index,element) =>
      imageId = $(element).data('id')
      @model.disable imageId,{},@callback('disable',$(element),imageId)
    window.location.href = "/images"








        
      

      
        
  
  
