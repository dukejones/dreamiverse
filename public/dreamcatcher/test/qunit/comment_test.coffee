module "Model: Dreamcatcher.Models.Comment"

test "get comments bedsheet [user]", ->
	stop()
	Dreamcatcher.Models.Comment.findComments 4109,{}, =>
	  ok true,"success"
