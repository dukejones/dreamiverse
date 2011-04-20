module("cookbook test",
	setup: ->
		S.open("//cookbook/cookbook.html")
)

test("Copy Test", ->
	equals(S("h1").text(),"Welcome to JavaScriptMVC 3.0!","welcome text")
)