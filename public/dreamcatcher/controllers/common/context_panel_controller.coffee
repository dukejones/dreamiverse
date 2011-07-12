$.Controller 'Dreamcatcher.Controllers.Users.ContextPanel', {
  pluginName: 'contextPanel'
}, {

  model: {
    user: User
  }
  
  init: (el) ->
    @element = $(el)
    @followButtonState = {}
    @polarFollowText = {none: 'follow', followed_by: 'befriend', following: 'unfollow', friends: 'unfriend'}
    @polarFollowRelationships = {none: 'following', followed_by: 'friends', following: 'follow', friends: 'following you'}
    @bindAjaxEvents()
 
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
    
    $("#relationship").removeClass(prevClass).addClass(newClass)
    $("#relationship").data('status', json.new_relationship)
    log "updated relationship to: #{json.new_relationship} prevClass: #{prevClass} newClass #{newClass}" 
        
  # DOM Listeners       
  
  'context_panel.book subscribe': (called, bookId) ->
    @model.user.contextPanel {book_id: bookId}, (html) =>
      $('#streamContextPanel').hide()
      $('#totem').replaceWith html
      @publish 'books.close', $('.book', @element)
      $('a.avatar', @element).hide()
      $('#totem').show().contextPanel()
      @publish 'app.initUi', $('#totem')
      $('.entryRemove', @element).droppable {         
        drop: (ev, ui) =>
          #maybe this could be tidier
          entryMeta = {book_id: ''}
          entryEl = ui.draggable
          entryEl.hide()
          Entry.update entryEl.data('id'), {entry: entryMeta}, => entryEl.remove()
        over: (ev, ui) =>
          $('.add-active', ui.helper).show()
          $('.entryRemove', @element).show()
        out: (ev, ui) =>
          $('.add-active', ui.helper).hide()
          $('.entryRemove', @element).hide()
      }
  
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
            section: 'Avatar'
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
    el.children(':first').text @followButtonState['currentText'] 
     
  '#relationship click': (el) ->
    currentRelationship = $("#relationship").data 'status'  
    followUsername = $("#relationship").data 'username'
    newRelationship = @polarFollowRelationships[currentRelationship]
    @followButtonState['currentText'] = newRelationship
    
    log("folowUsername: #{followUsername} newRelationship:#{newRelationship} currentRelationship: #{currentRelationship}")
  
    if currentRelationship is 'none' or currentRelationship is 'followed_by'     
      @model.user.follow({username: followUsername},@callback('updateFollowRelationship', el))
    else if currentRelationship is 'friends' or currentRelationship is 'following'
      @model.user.unfollow({username: followUsername},@callback('updateFollowRelationship', el))
      
      
  '.context click': (el) ->
    $('.view .details, .view .name', @element).toggle()
      
  '.change click': (el) ->
    $('.view', @element).hide()
    $('.edit', @element).show()
    
  '.cancel click': (el) ->
    $('.edit', @element).hide()
    $('.view', @element).show()
    
  bindAjaxEvents: ->
    $('form#update_profile').bind 'ajax:beforeSend', (xhr, settings)=>
      $('.edit', @element).hide()
      $('.view', @element).show()
      
      # Is this the best way to do this? Or should we use data coming back?

      $profileDetails = $('.profile .details')
      $user_url = $('#user_link_attributes_url').val()
      $user_url_href = $user_url.replace(/^www./, "http://www.") # needed for www. urls
      $user_url_href = 'http://' + $user_url unless ($user_url_href.match("^http")) # needed for domain.com urls
      log('new $user_url_href: ' + $user_url_href)

      $profileDetails.find('.website .href').text($user_url) # update link text
      $profileDetails.find('.website .href').attr('href',$user_url_href) # update link url
      $profileDetails.find('.email').text($('#user_email').val())
      $profileDetails.find('.phone').text($('#user_phone').val())
      $profileDetails.find('.skype').text($('#user_skype').val())
      $('.profile .view .name').text($('#user_name').val())
    
    $('form#update_profile').bind 'ajax:success', (data, xhr, status)=>
      $('.profile .alert').find('.check').show()
      $('.profile .alert').find('.close').hide()
      
      setTimeout("$('.profile .alert').hide();", 5000)
      
      # listen for close event
      $('.profile .alert').click ->
        $('.profile .alert').unbind()
        $('.profile .alert').hide()
        
      $('.profile .alert').find('.message').html('Profile has been updated')
      $('.profile .alert').show()
      
    ###
    $('form#update_profile').bind 'ajax:error', (xhr, status, error)=>
      $('.profile .alert').find('.check').hide()
      $('.profile .alert').find('.close').show()
      
      setTimeout =>
        $('.profile .alert').hide()
      , 5000
      # listen for close event
      $('.profile .alert').click ->
        $('.profile .alert').unbind()
        $('.profile .alert').hide()
        
      $('.profile .alert').find('.message').html(error)
      $('.profile .alert').show()
    ###
   
}
