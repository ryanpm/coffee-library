
do () ->
	window.loadServerContent = (container, action, callback, autoredirect) ->
		autoredirect = if (typeof autoredirect isnt 'undefined') then false else autoredirect

		$.ajax {
			url: urlsite + 'server/' + action,
			success: (response) ->

				try
					if( typeof response is 'string' )
						if( response.search('session_expired') isnt -1 )
							#window.modLoginStatusUpdate(true);
							modLogin ->
								loadServerContent(container, action, callback, autoredirect)
								return

							return

				$(container).html(response)
				if callback?
					callback(response)

		}

		return
	return