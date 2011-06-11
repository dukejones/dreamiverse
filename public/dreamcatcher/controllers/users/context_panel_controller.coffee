$.Controller 'Dreamcatcher.Controllers.Users.ContextPanel',

  model: {
    user: Dreamcatcher.Models.User
  }

  '.avatar, .book click': (el) ->
    if el.hasClass('book') and $('#showEntry').is(':visible')
      @historyAdd {
        controller: 'book'
        action: 'show'
        id: el.data 'id'
      }
    else
      @historyAdd {
        controller: 'entry'
        action: 'field'
      }
      
  '.uploadAvatar click': (el) ->
    $('#contextPanel').prepend $.View('//dreamcatcher/views/users/context_panel/avatar_upload.ejs')
    $('#avatarDrop').uploader {
      singleFile: true
      params: {
        image: {
          section: 'user uploaded'
          category: 'avatars'
          artist: $('#metaMenu .item.user span').text().trim()
        }
      }
      classes: {
        button: 'dropboxBrowse'
        drop: 'image'
        list: 'image'
      }
      onComplete: @callback 'uploadComplete'
    }

    
  uploadComplete: (id, fileName, result) ->
    $('#avatarDrop .uploading').remove()
    image = result.image
    if image?
      $('#contextPanel .avatar').css 'background-image', "url(/images/uploads/#{image.id}-avatar_main.#{image.format})"
      $('#avatarDrop').remove()
      @model.user.update { "user[image_id]": image.id }