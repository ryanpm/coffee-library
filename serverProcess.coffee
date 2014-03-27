do () ->

	server_loading_process = {}
	options = {}
	_parent = {}
	total_files_to_upload = 0
	action_id = ''

	sendInputs = (data , callback) ->
				_upd_info = '?'
				if( options.action.indexOf('?') isnt -1 )
					_upd_info  = '&'
				_upd_info  += '_files_total='+ total_files_to_upload
				if( $.trim(data) or options.type is 'get' )
					$.ajax {
						url: urlsite + 'server/' + options.action + _upd_info
						dataType: options.dataType
						type: options.type
						data: data
						success: callback
						error: (xhr, ajaxOptions, thrownError) ->
							if(thrownError)
								modAlert("Oooops! An error occured, please try again");
							return
					}

	onServerResponse = (result) ->
		try
			if ( typeof result is 'object' )
				if( result )
					if result.session_expired?
						checkIfExpired()
						return false;

		try
			if( typeof result is 'string' )
				if( result.search('session_expired') isnt -1 )
						checkIfExpired()
						return false;

		server_loading_process[action_id] = false

		if( options.dataType is 'json' )
			if (result is null || result is '' || typeof result is 'undefined')
				modAlert('Error accessing server please try again.')
				return
			if( options.autoredirect )
				if (result.logged_in is false)
					window.location.href = urlsite+'login'
					return

		try
	        options.callback result

		return


	checkIfExpired = ->
			modLogout()
			modLogin(connectToServer)
			return


	sendFileByIframe = ->
				submit_counter = 0

				serverProcessing() if options.show_process
				__form = options.data

				iframe_id = 'iframe_'+parseInt(Math.random()*99999999)
				__form.attr('method','post')
				__form.attr('action', urlsite + 'server/' + options.action)
				__form.attr('target', iframe_id)
				__form.attr('enctype','multipart/form-data')
				iframe = $('<iframe id="'+ iframe_id +'" src="about:blank" name="'+ iframe_id +'"  style="display:  "></iframe>').insertAfter(__form)

				if( __form.find('input[name=__submit__]').length is 0 )
					$('<input type="submit" style="display:none" name="__submit__" >').appendTo(__form)

				abortIframes = ->
					for frame in window.frames
						if( navigator.appName is "Microsoft Internet Explorer" )
							frame.document.execCommand('Stop')
						else
							frame.stop()
					return

				thread_submit_form =
					setInterval(
						->
							__form.find('input[name=__submit__]').click()
							submit_counter++
							return
					, 200)

				$ submit ->
					if( submit_counter > 3 )
						clearInterval(thread_submit_form)
						thread_submit_form = null
					return true

				iframe.load ->
					if $.trim(iframe.get(0).contentWindow.location.href is 'about:blank' )
						return null

					body = $(this).contents().find('body')
					html = $.trim(body.html())
					if( $.trim(html) is '')
						return null

				try

					html  = html.replace(/\\/g,'\\\\')
					match = html.match(/\{.*\}/)
					json  = $.parseJSON( match[0] )
					onServerResponse(json)

				catch e
					if( options.dataType is 'json' )
						onServerResponse({content:body.html()})
					else
						onServerResponse(body.html())

				clearInterval(thread_submit_form)
				thread_submit_form = null
				abortIframes()

				return

	sendFileByAjax = (callback) ->

		sendFileByAjaxClosure = () ->
			data = new FormData()

			$('input[type=file]', options.data ).each ->
				files = $(this).get(0).files
				name = $(this).attr('name')

				$.each files,
					(key, value)->
						data.append(name, value) if not isExcluded(name)
						return
				return

			_info = '?'
			if( options.action.indexOf('?') isnt -1 )
				_info  = '&'
			_info  += '_ajax_file_upd=1'

			$.ajax {
				url: urlsite + 'server/' + options.action + _info
				dataType: 'json'
				type: 'post'
				data: data
				cache: false
				processData: false
				contentType: false
				xhr: ->
					xhr = new window.XMLHttpRequest()

					xhr.upload.addEventListener "progress",
						(evt) ->
							if (evt.lengthComputable)
								percentComplete = evt.loaded / evt.total
								pb.progress( percentComplete * 0.90 ) if pb?
								return
						,false

					xhr.addEventListener "progress",
						(evt) ->
							if (evt.lengthComputable)
								percentComplete = evt.loaded / evt.total
							return
						,false

					return xhr

				success: (response) ->
					pb.progress(1) if pb

					setTimeout ->
						pb.close() if pb
						setTimeout ->
							callback(response)
							return
						,200
						return
					,1000

					if(options.onFileSuccess)
						options.onFileSuccess(_parent, response)

				error: (xhr, ajaxOptions, thrownError) ->
					if(thrownError)
						modAlert("Oooops! An error occured, please try again");
					return


			}
			return

		if options.show_process
			pb = modProgressBar('Uploading...', sendFileByAjaxClosure )
		else
			sendFileByAjaxClosure()

	sendFile = (callback) ->
		if( window.FormData is undefined )
			sendFileByIframe(callback)
		else
			sendFileByAjax(callback)

	isExcluded = (name) ->
		exclude = false
		if( options.excludeFile isnt null )
			console.log('options.excludeFile=')
			console.log(options.excludeFile)
			for ex_item in options.excludeFile
				console.log('ex_item=')
				console.log(ex_item)
				console.log('name=')
				console.log(name)
				if( ex_item == name  )
					exclude = true
		console.log(exclude)
		exclude

	connectToServer = ->
		if( typeof options.data is "object"  )
			total_inputs =  $('input[type!=file],select,textarea',options.data).length

			$('input[type=file]', options.data ).each ->
				if( $(this).val() isnt "" )
					total_files_to_upload++ if not isExcluded( $(this).attr('name') )
				return

			if( options.fileOnly )
				if( total_files_to_upload > 0 )
					sendFile (response) ->
						onServerResponse(response)
						pb.close() if pb
			else
				data = $('input[type!=file],select,textarea',options.data).serialize()
				if(data isnt '')
					sendInputs data,
						(response) ->
							_continue_sending = true
							if(options.onInputSuccess)
								_continue_sending = options.onInputSuccess(_parent, response) or true

							if(total_files_to_upload is 0 or !response.success or !_continue_sending)
								onServerResponse(response)
							else
								sendFile(onServerResponse)
							return


				else if( total_files_to_upload > 0 )
					sendFile (response) ->
						onServerResponse(response)
						pb.close() if pb

			return

		else
			ldr = serverProcessing() if options.show_process
			sendInputs options.data,
				(response) ->
					ldr.close() if ldr
					onServerResponse response
					return
		return

	window.serverProcess = (_options) ->
		defaults =
			action:''
			data:''
			type:'post'
			dataType:'json'
			show_process:false
			autoredirect:false
			callback:null
			onInputSuccess:null
			onFileSuccess:null
			fileOnly:false
			excludeFile:null

		options = $.extend( {}, defaults, _options)

		_parent =
			setAction: (action) ->
				options.action = action
				return

		action_id = options.action.replace('/','_')
		if( server_loading_process[action_id]? )
			server_loading_process[action_id] = false

		server_loading_process[action_id] = false

		if( server_loading_process[action_id] is false  )
			server_loading_process[action_id] = true
			connectToServer()
			return

	return

