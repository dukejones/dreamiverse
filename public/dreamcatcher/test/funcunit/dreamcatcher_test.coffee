module "Dreamcatcher test",
  setup: ->
    if $('.logOut')?
      S.open '/logout'
      S.wait 500
    S.open '/'
    
username = 'testuser'
password = '1234'

test "Welcome", ->
	equals S("h1:first").text(),"Welcome","Welcome text"
	
test "Enter login details", ->
  S('.login').click()
  S('.loginPanel').visible ->
  
    S('#user_username').click().val(username)
    equals( S('#user_username').val(), username, 'username' )

    S('#user_password').click().val(password)
    equals( S('#user_password').val(), password, 'password' )
    
test "Logging in", ->
  S('#loginButton').click()
  S('.rightPanel .user').visible ->
    equals( S('.rightPanel .user').text().trim(),username,"Logged in username" )
