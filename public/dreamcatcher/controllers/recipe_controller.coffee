$.Controller.extend('Cookbook.Controllers.Recipe',{
	onDocument: true
},{
	load: ->
		if !$("#recipe").length
			$(document.body).append($('<div/>').attr('id','recipe'))
			Cookbook.Models.Recipe.findAll({}, @callback('list'))
		 
	list: (recipes) ->
		$('#recipe').html(@view('init', {recipes:recipes} ))

	'form submit': ( el, ev ) ->
		ev.preventDefault()
		new Cookbook.Models.Recipe(el.formParams()).save()

	'recipe.created subscribe': ( called, recipe ) ->
		$("#recipe tbody").append( @view("list", {recipes:[recipe]}) )
		$("#recipe form input[type!=submit]").val("")

	'.edit click': ( el ) ->
		recipe = el.closest('.recipe').model()
		recipe.elements().html(@view('edit', recipe))
	
	'.cancel click': ( el ) ->
		@show(el.closest('.recipe').model())

	'.update click': ( el ) ->
		$recipe = el.closest('.recipe') 
		$recipe.model().update($recipe.formParams())

	'recipe.updated subscribe': ( called, recipe ) ->
		@show(recipe)
		
	'.destroy click': ( el ) ->
		if(confirm "Are you sure you want to destroy?")
			el.closest('.recipe').model().destroy()
	
	show: ( recipe ) ->
		recipe.elements().html(@view('show',recipe))
	
	"recipe.destroyed subscribe": (called, recipe) ->
		recipe.elements().remove()
})