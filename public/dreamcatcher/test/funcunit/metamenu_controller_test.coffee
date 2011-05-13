module "Dreamcatcher.Controller.MetaMenu test",

test "SettingsPanel open", ->
  S('.settingsPanel .trigger').click()
  S('#settingsPanel').visible ->
    ok 'settings panel showing'
    
#still to do:
#test body click
#test open appearance panel
#test open appearance panel while settings open (check if settings close)
