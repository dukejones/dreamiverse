$.Model.extend('Cookbook.Models.Recipe',{
	findAll: ( params, success, error ) ->
		$.ajax(
			url: '/recipe',
			type: 'get',
			dataType: 'json',
			data: params,
			success: @callback(['wrapMany',success])
			error: error
			fixture: "//cookbook/fixtures/recipes.json.get"
		)

	update: ( id, attrs, success, error ) ->
		$.ajax(
			url: '/recipes/'+id,
			type: 'put',
			dataType: 'json',
			data: attrs,
			success: success,
			error: error,
			fixture: "-restUpdate"
		)
	
	destroy: ( id, success, error ) ->
		$.ajax(
			url: '/recipes/'+id,
			type: 'delete',
			dataType: 'json',
			success: success,
			error: error,
			fixture: "-restDestroy"
		)
	
	create: ( attrs, success, error ) ->
		$.ajax(
			url: '/recipes',
			type: 'post',
			dataType: 'json',
			success: success,
			error: error,
			data: attrs,
			fixture: "-restCreate" 
		)

},
{})