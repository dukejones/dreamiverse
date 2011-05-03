module "Model: Dreamcatcher.Models.Comment"

entryId = 1167
userId = 246
newCommentId = null

test "findEntryComments", ->
	stop 2000
	Dreamcatcher.Models.Comment.findEntryComments entryId,{},(comments) ->
	  start()
	  ok(comments,"comments object")
	  ok(comments.length,"comments length")
	  ok(comments[0].body,"comments body attr")
	  ok(comments[0].entry_id is entryId,"entryId returned the same - ")

test "create", ->
  stop 2000
  comment = {
    user_id: userId
    body: 'testing 123'
  }
  Dreamcatcher.Models.Comment.create entryId,comment,(data) ->
    start()
    newComment = data.comment
    ok(newComment,"comment exists")
    ok(newComment.body is comment.body,"body the same")
    ok(newComment.entry_id is entryId,"entryId the same")
    newCommentId = newComment.id #this is used for delete (next)

test "delete", ->
	stop 2000
	Dreamcatcher.Models.Comment.delete entryId,newCommentId,->
	  start()
	  ok(true,"successfully deleted")
