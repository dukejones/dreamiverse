$.Controller 'Dreamcatcher.Controllers.Users.ContextPanel', {
  pluginName: 'contextPanel'
}, {

  model: {
    user: User
  }
  
  init: (el) ->
    @element = $(el)
    @loadingRelationship = false
    @followButtonState = {}
    @polarFollowText = {none: 'follow', followed_by: 'befriend', following: 'unfollow', friends: 'unfriend'}
    @polarFollowRelationships = {none: 'following', followed_by: 'friends', following: 'follow', friends: 'following you'}
 
  # Methods
  
  uploadComplete: (id, fileName, result) ->
    $('#avatarDrop .uploading').remove()
    image = result.image
    if image?
      $('#contextPanel .avatar').css 'background-image', "url(/images/uploads/#{image.id}-avatar_main.#{image.format})"
      $('#avatarDrop').hide()
      @model.user.update { "user[image_id]": image.id }

  updateFollowRelationship: (el,json) ->     
    prevClass = $("#relationship").attr('className')
    newClass = json.new_relationship
    newText = json.new_relationship
    newText = 'follow' if newText is 'none'
    newText = 'following you' if newText is 'followed_by'
    newText = @polarFollowText[@followButtonState['currentText']] if @loadingRelationship
    
    $("#relationship").removeClass(prevClass).addClass(newClass)
    el.children(':first').text newText
    $("#relationship").data('status', json.new_relationship)
    log "updated relationship to: #{json.new_relationship} newText: #{newText}" 
        
  # DOM Listeners       
  
  'context_panel.book subscribe': (called, bookId) ->
    @model.user.contextPanel {book_id: bookId}, (html) =>
      $('#streamContextPanel').hide()
      $('#totem').replaceWith html
      @publish 'books.close', $('.book', @element)
      $('a.avatar', @element).hide()
      $('#totem').show().contextPanel()
      @publish 'app.initUi', $('#totem')
  
  'context_panel.show subscribe': (called, username) ->
    username = $('#currentUserInfo').data 'username' unless username?
    if $('#contextPanel .context').text().trim() is username
      $('#streamContextPanel').fadeOut()
      $("#contextPanel .book").remove()
      $('#totem, #contextPanel, #contextPanel .avatar').show()
      
    else
      @model.user.contextPanel {username: username}, (html) =>
        $('#streamContextPanel').hide()
        $('#totem').replaceWith html
        $('#totem').show().contextPanel()
        @publish 'app.initUi', $('#totem')

  '.uploadAvatar click': (el, ev) ->
    ev.preventDefault()
    unless $('#avatarDrop').hasClass 'dreamcatcher_common_upload'
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
          drop: 'dropbox'
          #list: 'imagelist'
        }
        onComplete: @callback 'uploadComplete'
      }
    $('#avatarDrop, #avatarDropContainer').show()
    
  '#avatarDrop .cancel click': (el) ->
    $('#avatarDrop').hide()
      
  '#entry-filter change': (el) ->
    entryType = el.val()
    window.location.href = "/entries/?entry_type=#{entryType}"


  '#relationship mouseover': (el) ->
    currentRelationship = $("#relationship").data 'status'
    currentText = el.children(':first').text()
    hoverText = @polarFollowText[currentRelationship]   
    @followButtonState['currentText'] = currentText
    
    el.children(':first').text hoverText
    log("currentRelationship: #{currentRelationship} currentText: #{currentText} hoverText #{hoverText} ")

  '#relationship mouseout': (el) ->
    el.children(':first').text @followButtonState['currentText'] unless @loadingRelationship
     
  '#relationship click': (el) ->
    @loadingRelationship = true
    currentRelationship = $("#relationship").data 'status'  
    followUsername = $("#relationship").data 'username'
    newRelationship = @polarFollowRelationships[currentRelationship]
    @followButtonState['currentText'] = newRelationship
    
    log("folowUsername: #{followUsername} newRelationship:#{newRelationship} currentRelationship: #{currentRelationship}")
  
    if currentRelationship is 'none' or currentRelationship is 'followed_by'     
      @model.user.follow({username: followUsername},@callback('updateFollowRelationship', el))
    else if currentRelationship is 'friends' or currentRelationship is 'following'
      @model.user.unfollow({username: followUsername},@callback('updateFollowRelationship', el))
    
    @loadingRelationship = false
  
    
}
