module "Model: Dreamcatcher.Models.Settings"

userId = 7

test "update", ->
  stop 2000
  params = { 'user[default_landing_page]': 'stream' }

  Dreamcatcher.Models.Settings.update params ->
    start()
    ok(true,"successfully updated")