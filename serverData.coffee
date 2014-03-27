
do () ->
	window.getServerData = () ->
		$.ajax {
			url: urlsite + 'server/' + action,
			dataType: "json",
			type: 'post',
			data: data,
			success: (json) ->
				if json?
					modAlert('Error accessing server please try again.')
				if callback?
					callback(json)
		}
		return
	return