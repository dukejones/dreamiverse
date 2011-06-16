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
    log: ->
    warn: ->
  }
  root:
    join: ->
  then: (fn)-> 
    fn($)
    return ->
}
