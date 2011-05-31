$.Controller 'Dreamcatcher.Controllers.Entries',
  
  init: ->
    @index = new Dreamcatcher.Controllers.Entries.Index $('#entryField .matrix') if $("#entryField .matrix").exists()
    @books = new Dreamcatcher.Controllers.Entries.Books $('#entryField .matrix') if $("#entryField .matrix").exists()
    
  newBook: ->
    @books.newBook()