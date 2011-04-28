module "Model: Dreamcatcher.Models.Comment"

success: ->
  ok true,"success"

test "findEntryComments", ->
	stop 2000
	success = false
	failed = false
	Dreamcatcher.Models.Comment.findEntryComments 4109,{},(success=true),(failed=true)
	ok(success)

test "delete", ->
	stop 2000
	Dreamcatcher.Models.Comment.delete 4109,1368,{},(success=true),(failed=true)
	ok(success)
	
test "delete", ->
	stop 2000
	Dreamcatcher.Models.Comment.delete 4109,1368,{},(success=true),(failed=true)
	ok(success)
