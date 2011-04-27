$.Controller 'Dreamcatcher.Controllers.Comment',

  populate: (comments) ->
    entryId = comments[0].entry_id if comments.length > 0
    for entryComment in $(".comments")
      log $(entryComment).html()
      #log $(entryComment).find(".entry_id:first").val()
      #$(this).html @view('list',{comments: comments}) i

  '.comment click': (el) ->
    entryId = $(".entry_id",el.parent()).val()
    Dreamcatcher.Models.Comment.findComments entryId,{},@callback('populate')
    
