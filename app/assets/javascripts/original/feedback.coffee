$(document).ready ->
  feedbackController = new FeedbackController()
  $('#detailsForm').keyup ->
    window.fitToContent(this, 0)

class FeedbackController
  constructor: ()->
    @feedback = new FeedbackModel()
    @feedbackView = new FeedbackView(@feedback)
    
    $('#type').change =>
      @feedbackView.setType($('#type').val())
    $('#bugOptions').change =>
      @feedbackView.setBugOptions($('#bugOptions').val())

    $('#userAgent').val(navigator.userAgent) # save client os/browser ver
    log $('#userAgent').val()


class FeedbackView
  constructor: (feedbackModel) ->
    $('#submitButton, #details, #bugType').hide()
    $('#type').focus()
    
  setType: (type) ->
    switch type
      when "bug"
        $('#bugType').slideDown('fast')
        $('#details').slideUp('fast')
        $('#submitButton').fadeOut('fast')
        $('#bugOptions').focus()
        
      when "idea"
        $('#bugType').slideUp('fast')
        $('#details').slideDown('fast')
        $('#submitButton').fadeIn('fast')
        $('#detailsForm').focus()
        
      when "none"
        $('#bugType').slideUp('fast')
        $('#details').slideUp('fast')
        $('#submitButton').fadeOut('fast')
    
  setBugOptions: (bugOptions) ->
    switch bugOptions
      when "data not saving", "browser crash", "confusing feature", "other"
        $('#details').slideDown('fast')
        $('#submitButton').fadeIn('fast')
        $('detailsForm').focus()
      
      when "none"
        $('#details').slideUp('fast')
        $('#submitButton').fadeOut('fast')


class FeedbackModel
  constructor: ()->
    #nothing to do
