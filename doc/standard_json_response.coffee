# ok
{
  type: 'ok'
  message: 'user updated'
  html: '<b>some html</b>'
  entry: { json: 'object' }
}

# redirect
{
  type: 'redirect'
  to:   '/entries/36'
  # message ?
}


# Error: At least one of message and errors must be set.
# errors hash should be keyed to the attributes of the model that failed validation
{
  type: 'error'
  message: 'this is totally not correct.'
  errors: {
    old_password: 'dont you know your password?'
    password: 'confirmation is broke'
  }
}

# Alternative error syntax, when there are multiple models involved:
{
  type: 'error'
  message: 'there were errors in your entry'
  errors: {
    user: {
      old_password: 'dont you know your password?'
      password: 'confirmation is broke'
      name: 'cannot contain periods'
    }
    entry: {
      body: "can't be blank"
    }
  }
}