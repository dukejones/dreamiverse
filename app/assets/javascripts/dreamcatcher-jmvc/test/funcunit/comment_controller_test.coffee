module "Comment Test",



test "Test Comments Not Logged In", ->
	S(".randomDream").click()
	S(".commentsTarget").visible ->
	  count = parseInt(S(".commentsHeader .count span").text().trim())
	  ok(S(".prevCommentWrap").length is count)
	  