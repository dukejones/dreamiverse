module "Dreamcatcher test",
  setup: ->
    if $('.logOut')?
      S.open '/logout'
      S.wait 500
    S.open '/'

test "Welcome", ->
	equals S("h1:first").text(),"Welcome","Welcome text"
	
test "Enter login details", ->
  S('.login').click()
  S('.loginPanel').visible ->
    S('#user_username').click().val 'carboes'
    equals S('#user_username').val(),'carboes','User name'
    S('#user_password').click().val 'xo1234'
    equals S('#user_password').val(),'xo1234','Password'
    
test "Logging in", ->
  S('#loginButton').click()
  S('.rightPanel .user').visible ->
    equals S('.rightPanel .user').text().trim(),"carboes","User name"
