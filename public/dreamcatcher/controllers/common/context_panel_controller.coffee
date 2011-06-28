$.Controller 'Dreamcatcher.Controllers.Users.ContextPanel', {
  pluginName: 'contextPanel'
}, {

  model: {
    user: Dreamcatcher.Models.User
  }
  
  init: (el) ->
    @element = $(el)
    @currentRelationship = '' 
    @currentText = ''
    @followButtonState = {currentClass: '', hoverClass: ''}
    @polarFollowClass = {none: 'follow', following: 'unfollow', followed_by: 'befriend', friends: 'unfriend'}
    @polarFollowText = {none: 'followed_by', followed_by: 'befriend', following: 'unfollow', friends: 'unfriend'}
    # @polarFollowText['followed by'] = 'befriend' # above line syntax doesn't support spaces in keys   

    
  'context_panel.book subscribe': (called, bookId) ->
    @model.user.contextPanel {book_id: bookId}, (html) =>
      $('#streamContextPanel').hide()
      $('#totem').replaceWith html
      @publish 'books.close', $('.book', @element)
      $('a.avatar', @element).hide()
      $('#totem').show().contextPanel()
      @publish 'app.initUi', $('#totem')
  
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
  
  uploadComplete: (id, fileName, result) ->
    $('#avatarDrop .uploading').remove()
    image = result.image
    if image?
      $('#contextPanel .avatar').css 'background-image', "url(/images/uploads/#{image.id}-avatar_main.#{image.format})"
      $('#avatarDrop').hide()
      @model.user.update { "user[image_id]": image.id }
      
  '#entry-filter change': (el) ->
    # username = el.data 'username'
    entryType = el.val()
    #log entryType
    # window.location.href = "/#{username}/#{entryType}s"
    window.location.href = "/entries/?entry_type=#{entryType}"


  '#relationship mouseover': (el) ->
    @currentRelationship = $("#userDetails").data 'relationship'
    @currentText = el.children(':first').html()
    @hoverText = @polarFollowText[@currentRelationship]   
    @followButtonState['currentText'] = @currentText
    @followButtonState['hoverText'] = @hoverText
    
    log("@currentRelationship: #{@currentRelationship} @currentText: #{@currentText} @hoverText #{@hoverText}  @followButtonState[hoverClass] #{@followButtonState['hoverClass']}")
    @updateFollowButton(el,@hoverText)

  '#relationship mouseout': (el) ->
    #el.removeClass(@followButtonState['prevClass']).addClass @followButtonState['currentClass']
    el.children(':first').text @followButtonState['currentText']

  # '#relationship click': (el) ->
  #   @currentRelationship = $("#userDetails").data 'relationship'  
  #   @newRelationship = @polarFollowRelationships[@currentRelationship]  
  #   @username = $("#userDetails").data 'username'
  #   
  #   log("@username: #{@username} @newRelationship:#{@newRelationship} @currentRelationship: #{@currentRelationship}")
  # 
  #   if @currentRelationship is 'none' or @currentRelationship is 'followed_by'
  #     @model.user.follow({username: @username, verb: "#{@newRelationship}"},@callback('relationshipUpdated', el))
  #   else if @currentRelationship is 'friends' or @currentRelationship is 'following'
  #     @model.user.unfollow({username: @username, verb: "#{@newRelationship}"},@callback('relationshipUpdated', el))

  updateFollowButton: (el,text) ->
    log "updateFollowButton text: #{text} @followButtonState[hoverClass] #{@followButtonState['hoverClass']}"  
    el.children(':first').text('').text text

}
