avatarController = null

$(document).ready ->
  avatarController = new AvatarController('#contextPanel .avatar')

class AvatarController
  constructor: (containerSelector) ->
    @$container = $(containerSelector)
    @$avatarView = new AvatarView(containerSelector)
    @uploaderDisplayed = false
    
    @$container.find('.uploadAvatar').live 'click',  (event) =>
      @uploaderDisplayed = true
      
      $.subscribe 'uploader:init', (event) =>
        @setupUploader()
      
      $.subscribe 'uploader:created', (event) =>
        $('.cancel').click (event) =>
          @uploaderDisplayed = false
          @$avatarView.removeUploader()
        
      @$avatarView.displayUploader()
      
      # Stop event from bubbling up to DOM
      return false
    
    $.subscribe 'uploader:removed', (event) =>
      @uploaderDisplayed = false

    $('#contextPanel .avatar').live "mouseenter", (event) =>
      if !@uploaderDisplayed
        $('.avatar .uploadAvatarWrap').fadeIn('fast')
    .live "mouseleave", (event) =>
      $('.avatar .uploadAvatarWrap').fadeOut()

  setupUploader: ->
    @avatarParams = 
      image:
        section: "Avatar"
    uploader = new qq.AvatarUploader(
      element: document.getElementById('avatarDrop')
      action: '/images.json'
      maxConnections: 1
      params: @avatarParams
      debug: true
      onComplete: (id, fileName, response) =>
        avatar_url = '/images/uploads/' + response.image.id + '-avatar_main.' + response.image.format
        avatar_thumb = '/images/uploads/' + response.image.id + '-32x32.' + response.image.format
        
        # $.ajax {
        #           type: 'PUT'
        #           url: '/user.json'
        #           dataType: 'json'
        #           data:
        #             "user[image_id]": response.image.id
        #           success: (data, status, xhr) =>
        #             alert 'updated avatar!  '
        #         }
        
        @uploaderDisplayed = false
        @$avatarView.removeUploader(avatar_url, avatar_thumb)
    )

    
class AvatarView
  constructor: (containerSelector) ->
    @$container = $(containerSelector)
    @$contextPanel = $('#contextPanel')
    
  displayUploader: ->
    @displayBodyClick()
    
    
    @$contextPanel.find('.avatar').hide()
    @$contextPanel.css('z-index', '1200')
    @$contextPanel.prepend("<div id='avatarDrop' class='uploader'><div class='qq-upload-drop-area' id='avatarDropContainer'><div class='text'><a xmlns='http://www.w3.org/1999/xhtml'>drag new image here</a></div><div class='browse'><div class='toggle'><a xmlns='http://www.w3.org/1999/xhtml'>browse for a file</a></div><div class='cancel'><a xmlns='http://www.w3.org/1999/xhtml'>cancel</a></div><div class='dropboxBrowse'><a xmlns='http://www.w3.org/1999/xhtml'>browse</a></div></div></div></div>")
    
    $.publish 'uploader:init', [@container]
  
  removeUploader: (avatar_path = 'old', avatar_thumb_path = 'old')->
    $('#bodyClick').remove()
    
    $.publish 'uploader:removed', [this]
    
    log avatar_path
    log avatar_thumb_path
    if avatar_path isnt 'old'
      log @$container
      log "MADE IT"
      @$container.css('background-image', 'url(' + avatar_path + ')')
      $('.rightPanel .user').css('background-image', 'url(' + avatar_thumb_path + ')')
    
    $('#avatarDrop').remove()
    @$contextPanel.css('z-index', 'auto')
    $('.uploadAvatarWrap').hide()
    @$container.show()
  
  displayBodyClick: ->
    bodyClick = '<div id="bodyClick" style="z-index: 1100; cursor: pointer; width: 100%; height: 100%; position: fixed; top: 0; left: 0;" class=""></div>'
    $('body').prepend(bodyClick)
  
    $('html, body').animate({scrollTop:0}, 'slow');
  
    $('#bodyClick').click( (event) =>
      @removeUploader()
      $('#bodyClick').remove()
    )