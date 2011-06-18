$.Controller 'Dreamcatcher.Controllers.Users.ContextPanel', {
  pluginName: 'contextPanel'
}, {

  model: {
    entry : Dreamcatcher.Models.Entry
    user: Dreamcatcher.Models.User
  }
  
  init: (el) ->
    @element = $(el)
    
  'context_panel.book subscribe': (called, bookId) ->
    @model.user.contextPanel {book_id: bookId}, (html) =>
      $('#streamContextPanel').hide()
      $('#totem').replaceWith html
      @publish 'books.close', $('.book', @element)
      $('a.avatar', @element).hide()
      $('#totem').show().contextPanel()
  
  'context_panel.show subscribe': (called, username) ->
    username = $('#userInfo').data 'username' unless username?
    if $('#contextPanel .context').text().trim() is username
      $('#streamContextPanel').fadeOut()
      $("#contextPanel .book").remove()
      $('#totem, #contextPanel, #contextPanel .avatar').show()
      
    else
      @model.user.contextPanel {username: username}, (html) =>
        $('#streamContextPanel').hide()
        $('#totem').replaceWith html
        $('#totem').show().contextPanel()

  '.uploadAvatar click': (el) ->
    $('#contextPanel').prepend $.View('/dreamcatcher/views/users/context_panel/avatar_upload.ejs')
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