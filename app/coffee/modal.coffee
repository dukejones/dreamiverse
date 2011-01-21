dc ?= {}

dc.modal = ->
  $("<div>You should use Chrome Frame. Our site doesn't work on jank browsers like IE 6.</div>").dialog({
    modal: true
    buttons: {
      "Ok": ->
        console.log('ok')
        $(this).dialog("close")
      "Cancel": ->
        console.log('no way')
        $(this).dialog("close")
    }
  })