log = (msg)-> console.log(msg) if console?

# For adding hoverIntent:
# http://rndnext.blogspot.com/2009/02/jquery-live-and-plugins.html

$('.userNode').live('mouseenter mouseleave click', (event) ->

  switch event.type
    when 'mouseenter'
      $(this).find('.statusHover').fadeIn('fast')
    when 'mouseleave'
      $(this).find('.statusHover').fadeOut('fast')
    when 'click'
      $.publish('follow/change', [$(this)])
)

$.subscribe('follow/change', (userNode) ->
  # what is the current following status?
  # change it to its opposite: unfollow => follow, follow => unfollow
  log 'changing...'
  follow = new Follow(userNode)
  follow.change()
)
$.subscribe('follow/changed', (userNode) ->
  followButton = new FollowButton(userNode)
  
)

# Data View
class FollowButton
  @for: ->
  constructor: (userNode)->
    @userNode = userNode

  
# Model
class Follow
  constructor: ($node)->
    @$userNode = $node
    @id = @$userNode.attr('userId')
    @state = @$userNode.attr('followState')
  possibleStates: ["following", "notfollowing", "changing"]
  change: ->
    switch @state
      when "following"
        @unfollow()
      when "notfollowing"
        @follow()
      else
        log "changing"
  follow: ->
    $.publish('follow/changing', [@$userNode])
    $.post('/users/follow', {action: 'follow'}, (data) =>
      log data
      $.publish('follow/changed', [@$userNode]) # or pass this
    )
  unfollow: ->
    $.publish('follow/changing', [@$userNode])
    $.post('/users/follow', {action: 'unfollow'}, (data) =>
      log data
      $.publish('follow/changed', [@$userNode])
    )


