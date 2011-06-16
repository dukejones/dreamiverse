log = (msg)-> console.log msg


steal = {
  plugins: -> 
    return steal
  resources: -> return steal
  models:  -> return steal
  views: -> return steal
  coffee: -> return steal
  dev: {
    isHappyName: ->
  }
  root:
    join: ->
  then: (fn)-> 
    fn($)
    return ->
}
