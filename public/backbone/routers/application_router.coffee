
class ApplicationRouter extends Backbone.Router
  routes: 
    "": "index"
    
  constructor: ->
    
  index: ->
    alert 'index'
    
$ ->
  new ApplicationRouter()
  Backbone.history.start({pushState: true})
  