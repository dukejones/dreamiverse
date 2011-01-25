dc ?= {}

dc.modal = ->
  $("<div>You should use Chrome Frame. Our site doesn't work on jank browsers like IE 6.</div>").dialog({
    modal: true
    dialogClass: 'light O O-shine'
    buttons: {
      "Cancel": ->
        console.log('no way')
        $(this).dialog("close")
      "Ok": ->
        console.log('ok')
        $(this).dialog("close")
    }
  })