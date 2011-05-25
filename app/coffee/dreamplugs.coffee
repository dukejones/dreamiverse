
$(document).ready ->
  setupDreamplugs()
  
  
# init
window.setupDreamplugs = ->
  # Setup slide triggers to work
  $('.trigger.slide').click( (event) ->
    $newTargetSlide = $(event.currentTarget).parent().find('.target.slide')
    
    if $newTargetSlide.css('display') is 'none'
      $newTargetSlide.slideDown(250)
    else
      $newTargetSlide.slideUp(250)
  )
  
  # Setup slide w/ arrows to work
  # Used for Stream filtering
  $('.trigger.slideArrow').click( (event) ->
    $newTargetSlideArrow = $(event.currentTarget).parent().find('.target.slideArrow')
    $toggleText = $(event.currentTarget).find('.value')
    $toggleIcon = $(event.currentTarget).find('.icon')
    
    offsetSize = 30
    
    if $newTargetSlideArrow.css('display') is 'none'
      $newTargetSlideArrow.fadeIn(250)
      
      # Create bodyclick
      $('#bodyClick').show()
    
      $('#bodyClick').click( (event) =>
        $newTargetSlideArrow.hide()
        $('#bodyClick').hide()
      )
      
      $newTargetSlideArrow.find('.type').unbind()
      $newTargetSlideArrow.find('.type').click( (event) ->
        $('#bodyClick').hide()
        
        newIcon = $(event.currentTarget).find('img').attr('src')
        $toggleIcon.attr('src', newIcon)

        #newText = $(event.currentTarget).find('span').text()
        newText = $(event.currentTarget).find('span').text()
        $toggleText.text(newText)
        
        # Publish event for the Stream (or wherever its used) to listen to
        $.publish 'filter:change'
        
        index = $(event.currentTarget).index()
        newPosition = index * offsetSize
        newPositionString = -newPosition + 'px'
        $newTargetSlideArrow.fadeOut(0, (event) ->
          $newTargetSlideArrow.css('top', newPositionString)
        )
      )
      
    else
      $newTargetSlideArrow.hide()
      
  )
  
  # Setup showhide triggers
  $('.trigger.showhide').live( 'click', (event)->
    $newTargetShowHide = $(event.currentTarget).parent().find('.target.showhide')
    if $newTargetShowHide.css('display') is 'none'
      $newTargetShowHide.show()
    else
      $newTargetShowHide.hide()
  )
  
  # Setup showhide SEARCH triggers
  $('.trigger.showhidesearch').click( (event) ->
    $newTargetShowHide = $(event.currentTarget).parent().find('.target.showhidesearch')
    if $newTargetShowHide.css('display') is 'none'
      $newTargetShowHide.show()
      $('#search_string').focus()
      $('#bodyClick').show()
      $('#bodyClick').click( (event) =>
        $newTargetShowHide.fadeOut(250)
        $('#bodyClick').hide()
      )
    else
      $newTargetShowHide.fadeOut(250)
      $('#bodyClick').hide()
  )
  
  # Setup showhide triggers FOR EMOTIONS PANEL
  # $('.trigger.emotionshowhide').click( (event) ->
  #   $newTargetShowHide = $(event.currentTarget).parent().find('.target.emotionshowhide')
  #   
  #   if $newTargetShowHide.css('display') is 'none'
  #     $newTargetShowHide.show()
  #     bodyClick = '<div id="bodyClick" style="z-index: 1100; cursor: pointer; width: 100%; height: 100%; position: fixed; top: 0; left: 0;" class=""></div>'
  #     $('body').prepend(bodyClick)
  #   
  #     $('#bodyClick').click( (event) =>
  #       $newTargetShowHide.hide()
  #       $('#bodyClick').remove()
  #     )
  #   else
  #     $newTargetShowHide.hide()
  #     $('#bodyClick').remove()
  # )
  
  # Setup showhide triggers REMOVES CLICKED ELEMENT
  $('.trigger.showhideremove').click( (event) ->
    $newTargetShowHide = $(event.currentTarget).parent().find('.target.showhideremove')
    $(event.currentTarget).hide()
   
    if $newTargetShowHide.css('display') is 'none'
      $newTargetShowHide.show()
    else
      $newTargetShowHide.hide()
  )
  
  # Setup fade triggers to work
  $('.trigger.fade').click( (event) ->
    $newTargetFade = $(event.currentTarget).parent().find('.target.fade')
    
    if $newTargetFade.css('display') is 'none'
      $newTargetFade.fadeIn(250)
    else
      $newTargetFade.fadeOut(250)
  )
  
  # Setup fade w/ bodyclick triggers to work
  $('.trigger.fadeclick').click( (event) ->
    $newTargetFade = $(event.currentTarget).parent().find('.target.fadeclick')
    
    if $newTargetFade.css('display') is 'none'
      # Create bodyclick
      $("#bodyClick").show()
    
      $('html, body').animate({scrollTop:0}, 'slow');
    
      $('#bodyClick').click( (event) =>
        $newTargetFade.hide()
        $('#bodyClick').hide()
      )
      
      $newTargetFade.fadeIn(250)
    else
      $newTargetFade.fadeOut(250)
      $('body').remove()
  )
  
  # Setup toggle handler
  $('.trigger.toggle').click( (event) ->
    $newTargetToggle = $(event.currentTarget).parent().parent().find('.target.toggle')
    $oldTargetToggle = $(event.currentTarget).parent()
    
    $oldTargetToggle.hide()
    $newTargetToggle.show()
  )