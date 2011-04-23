module "Model: Dreamcatcher.Models.Appearance"

#TODO: add success function, to say ok.
#TODO: add test entities in db.

test "update bedsheet [user]", ->
	stop()
	#must be logged in.
	Dreamcatcher.Models.Appearance.update null,{bedsheet_id: 1}, =>
	  ok true,"success"

###
test("update bedsheet [entry]", ->
	stop()
	Dreamcatcher.Models.Appearance.update(1,{bedsheet_id: 1})
)
test("update scrolling [user]", ->
	stop()
	Dreamcatcher.Models.Appearance.update(null,{scrolling: "fixed"})
)
test("update scrolling [entry]", ->
	stop()
	Dreamcatcher.Models.Appearance.update(1,{scrolling: "scroll"})
)
test("update theme [user]", ->
	stop()
	Dreamcatcher.Models.Appearance.update(null,{scrolling: "light"})
)
test("update theme [entry]", ->
	stop()
	Dreamcatcher.Models.Appearance.update(1,{scrolling: "dark"})
)
###