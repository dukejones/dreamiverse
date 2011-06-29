$.Controller 'Dreamcatcher.Controllers.Users.ContextPanel', {
  pluginName: 'contextPanel'
}, {

  model: {
    user: User
  }
  
  init: (el) ->
    @element = $(el)
    @currentRelationship = '' 
    @currentText = ''
    @followButtonState = {currentClass: '', hoverClass: ''}
    @polarFollowText = {none: 'follow', followed_by: 'befriend', following: 'unfollow', friends: 'unfriend'}
    @polarFollowRelationships = {none: 'following', following: 'follow', followed_by: 'friends', friends: 'following you'}


  # Methods
  
  uploadComplete: (id, fileName, result) ->
    $('#avatarDrop .uploading').remove()
    image = result.image
    if image?
      $('#contextPanel .avatar').css 'background-image', "url(/images/uploads/#{image.id}-avatar_main.#{image.format})"
      $('#avatarDrop').hide()
      @model.user.update { "user[image_id]": image.id }

  updateFollowButton: (el,text, className=null) ->
    log "updateFollowButton text: #{text} @followButtonState[hoverClass] #{@followButtonState['hoverClass']}"  
    el.children(':first').text('').text text

  updateFollowRelationship: (el,json) -> 
    log 'updated relationship to: ' + json.new_relationship
    $("#relationship").data('status', json.new_relationship)
    @prevClass = $("#relationship").attr('className')
    $("#relationship").removeClass(@prevClass).addClass(json.new_relationship)
    
    @newText = if json.new_relationship is 'none' then 'follow' else json.new_relationship
    el.children(':first').text('').text @newText
        
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
    @currentRelationship = $("#relationship").data 'status'
    @currentText = el.children(':first').text()
    @hoverText = @polarFollowText[@currentRelationship]   
    @followButtonState['currentText'] = @currentText
    log("@currentRelationship: #{@currentRelationship} @currentText: #{@currentText} @hoverText #{@hoverText} ")
    @updateFollowButton(el,@hoverText)

  '#relationship mouseout': (el) ->
    el.children(':first').text @followButtonState['currentText']

  '#relationship click': (el) ->
    @currentRelationship = $("#relationship").data 'status'  
    @followUsername = $("#relationship").data 'username'
    @newRelationship = @polarFollowRelationships[@currentRelationship]  
    @followButtonState['newText']
    
    log("@username: #{@username} @newRelationship:#{@newRelationship} @currentRelationship: #{@currentRelationship}")
  
    if @currentRelationship is 'none' or @currentRelationship is 'followed_by'     
      @model.user.follow({username: @followUsername},@callback('updateFollowRelationship', el))
    else if @currentRelationship is 'friends' or @currentRelationship is 'following'
      @model.user.unfollow({username: @followUsername},@callback('updateFollowRelationship', el))
  
    
}
