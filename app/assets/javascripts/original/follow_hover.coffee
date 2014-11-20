
$(document).ready ->
  refreshUserNodes()
  
# attaching to window object means it can be accessed outside of the enclosing closure.
window.refreshUserNodes = ->
  for node in $('.userNode') 
    button = new FollowButton(node)
    button.refresh()


$.subscribe('follow/change', (userNode) ->
  follow = new Follow(userNode)
  follow.change()
)
$.subscribe('follow/changed', (userNode) ->
  followButton = new FollowButton(userNode)
  followButton.refresh()
)
$.subscribe('follow/changing', (userNode) ->
  followButton = new FollowButton(userNode)
  followButton.loadingState()
)


# For adding hoverIntent:
# http://rndnext.blogspot.com/2009/02/jquery-live-and-plugins.html

$('.backdrop, .userInfo').live('click', (event) ->
  expandNode = $(this).parent().find('.expanded')
  node = $(this).parent()
  if expandNode.css('display') is 'none' 
    expandNode.slideDown(250)
    zIndex = $('#friendField').data('id')
    zIndex++
    node.css('z-index', zIndex)
    $('#friendField').data('id', zIndex)
  else
    expandNode.slideUp(250)
)

$('.userNode').live('mouseenter mouseleave', (event) ->
  switch event.type
    when 'mouseenter'
      $(this).find('.statusHover').fadeIn(250)
    when 'mouseleave'
      $(this).find('.statusHover').fadeOut(250)
)

$('.userNode .statusHover, .userNode .status').live('click', (event)->
  $.publish('follow/change', [$(this).parent()[0]])
  return false
)

# Data View
class FollowButton
  constructor: (userNode)->
    @$userNode = $(userNode)
    @follow = new Follow(userNode)
  refresh: ->
    $status = @$userNode.find('.status')
    $actionWord = @$userNode.find('span')
    $status.removeClass('none following followed_by friends')
    switch @follow.state()
      when "none"
        $status.addClass('none')
        $actionWord.text('follow');
      when "following"
        $status.addClass('following')
        $actionWord.text('unfollow');
      when "followed_by"
        $status.addClass('followed_by')
        $actionWord.text('befriend');
      when "friends"
        $status.addClass('friends')
        $actionWord.text('unfriend');
        
  loadingState: ->
    # not yet implemented

  
# Model
class Follow
  constructor: (node)->
    @$userNode = $(node)
  id: -> @$userNode.attr('userId')
  state: -> @$userNode.attr('relationshipWith')
  setState: (newState) ->
    @$userNode.attr('relationshipWith', newState)
  change: ->
    switch @state()
      when "following", "friends"
        @unfollow()
      when "none", "followed_by"
        @follow()
      else
        log "changing: invalid state! #{@state()}"
  follow: ->
    node = @$userNode[0]
    user = @$userNode.find('.userInfo h3').text()
    $.publish('follow/changing', [node])
    $.post('/' + user + '/follow.json', {user_id: @id(), verb: 'follow'}, (data) =>
      if @state() is 'none' then @setState('following') else @setState('friends')

      $.publish('follow/changed', [node])
    )
  unfollow: ->
    node = @$userNode[0]
    user = @$userNode.find('.userInfo h3').text()
    $.publish('follow/changing', [node])
    $.post('/' + user + '/unfollow.json', {user_id: @id(), verb: 'unfollow'}, (data) =>
      if @state() is 'following' then @setState('none') else @setState('followed_by')

      $.publish('follow/changed', [node])
    )


