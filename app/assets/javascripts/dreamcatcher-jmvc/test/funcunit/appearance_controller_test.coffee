module "Dreamcatcher.Controller.Appearance test",

test "Change profile bedsheet", ->
  S(".home").click()
  S(".appearance").visible ->
    S(".appearance").click()
    S("#bedsheetScroller ul li:first").visible ->
      #S("#bedsheetScroller ul li:first")
  
  
#load default genre
#select new genre
#select bedsheet (could be in new Bedsheet_controller_test perhaps?)
#select scrolling
#select theme

#entry mode
#new entry
#normal view