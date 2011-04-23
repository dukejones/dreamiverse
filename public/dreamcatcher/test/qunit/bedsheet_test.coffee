module "Model: Dreamcatcher.Models.Bedsheet"

testBedsheet: (bedsheets) ->
  start()
  ok bedsheets

test "findAll", ->
  stop 2000
  Dreamcatcher.Models.Bedsheet.findAll {},(bedsheets) =>
    start()
    ok bedsheets
    ok bedsheets.length
    ok bedsheets[0]

test "findAll [genre does NOT exist]", ->
  stop 2000
  Dreamcatcher.Models.Bedsheet.findAll {genre: 'test123'}, (bedsheets) =>
    start()
    ok bedsheets
    ok bedsheets.length is 0

test "findAll [genre does exist]", ->
  stop 2000
  Dreamcatcher.Models.Bedsheet.findAll {genre: 'space'}, (bedsheets) =>
    start()
    ok bedsheets
    ok bedsheets.length
    ok bedsheets[0]