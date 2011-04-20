module("Model: Dreamcatcher.Models.Bedsheet")

test("findAll", ->
	stop 2000
	Dreamcatcher.Models.Bedsheet.findAll({},
		start()
		ok(bedsheets)
        ok(bedsheets.length)
        ok(bedsheets[0].id)
  )
)