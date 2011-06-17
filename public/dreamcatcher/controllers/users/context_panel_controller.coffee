$.Controller 'Dreamcatcher.Controllers.Users.ContextPanel', {
  pluginName: 'contextPanel'
}, {

  model: {
    entry : Dreamcatcher.Models.Entry
    user: Dreamcatcher.Models.User
  }
  
  init: (el) ->
    @element = $(el)
  
  'context_panel.book.element subscribe': (called, html) ->
    if $('.book', @element).exists()
      $('.book', @element).replaceWith html
    else
      $('#contextPanel', @element).prepend html
      
    href = $('a.avatar', @element).attr 'href'
    $('.book a.mask', @element).attr 'href', href 
    $('.avatar', @element).fadeOut()
    
  'context_panel.book.id subscribe': (called, bookId) ->
    @model.user.contextPanel {book_id: bookId}, (html) =>
      $('#streamContextPanel').hide()
      $('#totem').replaceWith html
      @publish 'books.close', $('.book', @element)
      $('a.avatar', @element).hide()
      $('#totem').show()
  
  
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
        $('#totem').show()

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