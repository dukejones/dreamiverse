$.Controller 'Dreamcatcher.Controllers.Users.ContextPanel', {
  pluginName: 'contextPanel'
}, {

  model: {
    entry : Dreamcatcher.Models.Entry
    user: Dreamcatcher.Models.User
  }
  
  'context_panel.show subscribe': (called, username) ->
    log username
    @model.user.contextPanel username, (html) =>
      $('#streamContextPanel').hide()
      $('#totem').replaceWith html
      $('#totem').show()

  '.uploadAvatar click': (el) ->
    $('#contextPanel').prepend $.View('//dreamcatcher/views/users/context_panel/avatar_upload.ejs')
    $('#avatarDrop').uploader {
      singleFile: true
      params: {
        image: {
          section: 'user uploaded'
          category: 'avatars'
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

}