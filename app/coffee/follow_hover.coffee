window.log = (msg)-> console.log(msg) if console?


$(document).ready ->
  refreshUserNodes()
  
# attaching to window object means it can be accessed outside of the enclosing closure.
window.refreshUserNodes = ->
  $('.userNode').each (i, node)->
    button = new FollowButton(node)
    button.refresh()

# For adding hoverIntent:
# http://rndnext.blogspot.com/2009/02/jquery-live-and-plugins.html
$('.userNode').live('mouseenter mouseleave click', (event) ->
  switch event.type
    when 'mouseenter'
      $(this).find('.statusHover').fadeIn('fast')
    when 'mouseleave'
      $(this).find('.statusHover').fadeOut('fast')
    when 'click'
      $.publish('follow/change', [this])
)

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
  followButton.intermediateState()
)

# Data View
class window.FollowButton
  constructor: (userNode)->
    @$userNode = $(userNode)
    @follow = new Follow(userNode)
  refresh: ->
    switch @follow.state()
      when "following"
        @followingState()
      when "notfollowing"
        @notfollowingState()
      
  followingState: ->
    @$userNode.find('.status').css('background-position', '0 33%')
    @$userNode.find('span').text('unfollow');
    
  notfollowingState: ->
    @$userNode.find('.status').css('background-position', '0 0%')
    @$userNode.find('span').text('follow');
  intermediateState: ->
    # not yet implemented

  
# Model
class Follow
  constructor: (node)->
    @$userNode = $(node)
  possibleStates: ["following", "notfollowing", "changing"]
  id: -> @$userNode.attr('userId')
  state: -> @$userNode.attr('followState')
  setState: (newState) ->
    @$userNode.attr('followState', newState)
  change: ->
    switch @state()
      when "following"
        @unfollow()
      when "notfollowing"
        @follow()
      else
        log "changing: invalid state! #{@state()}"
  follow: ->
    node = @$userNode[0]
    $.publish('follow/changing', [node])
    $.post('/user/follow', {user_id: @id(), verb: 'follow'}, (data) =>
      log data
      @setState('following')
      $.publish('follow/changed', [node])
    )
  unfollow: ->
    node = @$userNode[0]
    $.publish('follow/changing', [node])
    $.post('/user/follow', {user_id: @id(), verb: 'unfollow'}, (data) =>
      log data
      @setState('notfollowing')
      $.publish('follow/changed', [node])
    )


