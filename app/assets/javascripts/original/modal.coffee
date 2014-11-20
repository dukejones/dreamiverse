dc = {} if dc?

dc.modal = ->
  $("<div>Your web browser is incompatible with Dreamcatcher.net. Please install Google's Chrome Frame to fix the issue.</div>").dialog({
    title: 'Incompbatible browser'
    modal: true
    width: 358
    dialogClass: 'static-glow-40'
    closeText: ''
    buttons: {
      "Ok": ->
        # log('ok')
        $(this).dialog("close")
      "Cancel": ->
        # log('no way')
        $(this).dialog("close")
    }
  })