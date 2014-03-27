
do () ->
	window.modProgressBar = (message, callback) ->
		_id = parseInt(Math.random()*99999999)
		openColorBox({
			html:"<div><div style='background:#ee1f37;padding:5px'><h4 style='padding:0px;margin:0px'>Progress</h4></div><div style='padding:10px;' > #{message} </div><div style='text-align:right;padding:5px;'><br/><span id='modProgressBar_percent_#{_id}'>0%</span><div style='width:100%;border:1px solid white;height:10px;'><div style='background:white;width:0%;height:10px' id='modProgressBar_bar_#{_id}' ></div></div></div></div>",
			transition:'none',
			height:'170px',
			width:'450px',
			fixed:true,
			overlayClose: false,
			title:false,
			closeButton:false,
			onComplete: callback
		})

		{
			progress:  (percent) ->
				$('#modProgressBar_percent_'+_id).html( "#{parseInt(percent*100)}%" );
				$('#modProgressBar_bar_'+_id).css('width', "#{parseInt(percent*100)}%");
				return
			close: () ->
				$.colorbox.close()
				return
		}


	window.modTimer_closer;
	window.closeColorBox = () ->
		return if $.colorbox is null


		clearTimeout(window.modTimer_closer) if window.modTimer_closer?

		window.modTimer_closer =
		setTimeout ->
				$.colorbox.close()
				return
			,300

		return


	window.openColorBox = (options) ->
		return if $.colorbox is null
		clearTimeout(modTimer_closer) if modTimer_closer?

		setTimeout ->
				$.colorbox(options);
				return
			,200

		return

	window.modAlertFunctions = {};
	window.modAlert = (message, callback) ->
		_id = parseInt(Math.random()*99999999)

		window.modAlertFunctions['ok_'+_id] = () ->
			closeColorBox()
			try
				callback()

		if message?
			message = message.replace(new RegExp('\n', 'g'),'<br/>')

		openColorBox({
			html:"<div><div style='background:#ee1f37;padding:5px'><h4 style='padding:0px;margin:0px'>Alert!</h4></div><div style='padding:10px;height:60px' >#{message}</div><div style='text-align:right;padding:5px;'><input type='button'   onclick='modAlertFunctions.ok_#{_id}(); ' value='   OK   ' class='btn_red02' style='cursor:pointer'></div></div>",
			transition:'none',
			height:'170px',
			width:'450px',
			fixed:true,
			title:false,
			closeButton:false
		})

	#window.serverProcessing_flag = false

	window.serverProcessing = (message='Processing!', title='Progess') ->

		_id = parseInt(Math.random()*99999999)
		openColorBox({
			html:"<div><div style='background:#ee1f37;padding:5px'><h4 style='padding:0px;margin:0px' >#{title}</h4></div><div style='padding-top:20px;padding-left:20px'   id='modLoaderMessage_#{_id}'  >#{message}</div><div style='padding-top:25px;height:20px;padding-left:105px;float:left' ><img id='ajax_loader' src='#{urlbase}images/ajax-loader.gif'></div><div style='float: left; font-size:12px;color:222222;padding-top:35px;'></div></div>",
			transition:'none',
			height:'160px',
			width:'370px',
			fixed:true,
			title:false,
			overlayClose: false,
			escKey:false,
			closeButton:false
		})

		$('#_ajax_loader').insertAfter('#ajax_loader')

		#window.serverProcessing_flag = flag

		{
			setMessage:  (message) ->
				$('#modLoaderMessage_'+_id).html( message );
				return
			close: () ->
				$.colorbox.close()
				return
		}

	window.modConfirmFunctions = {};
	window.modConfirm = (message, callback_yes, callback_no) ->
		_id = parseInt(Math.random()*99999999)
		window.modConfirmFunctions['yes_'+_id] = () ->
			closeColorBox()
			if( callback_yes isnt undefined )
				callback_yes()
			return
		window.modConfirmFunctions['no_'+_id] = () ->
			closeColorBox()
			if( callback_no isnt undefined )
				callback_no()
			return

		if message?
			message = message.replace(new RegExp('\n', 'g'),'<br/>');

		openColorBox({
			html:"<div><div style='background:#ee1f37;padding:5px'><h4 style='padding:0px;margin:0px'>Confirm!</h4></div><div style='padding:10px;height:60px' >#{message}</div><div style='text-align:right;padding:5px;'><input name='yes' type='button' onclick='modConfirmFunctions.yes_#{_id}(); ' value='   Yes   ' class='btn_red02' style='cursor:pointer'><input name='no'  type='button' onclick='modConfirmFunctions.no_#{_id}();' value='   No   ' class='btn_red02' style='cursor:pointer;margin-left:10px'></div></div>"
			transition:'none'
			height:'170px'
			width:'450px'
			fixed:true
			closeButton:false
		});

		return

	window.show_server_response_ids = {}
	window.showSuccess = (container,message,delay=3000,callback) ->
		_id = $(container).attr('id')
		if typeof _id is 'undefined'
			_id = parseInt(Math.random() * 99999999);
			$(container).attr('id', '_id_' + _id );
		if window.show_server_response_ids[_id]?
			clearTimeout(window.show_server_response_ids[_id])

		if( $.trim(message) isnt '' )
			$(container).html("<div class='error'>#{message}</div>").show()
			window.show_server_response_ids[_id] = setTimeout ->
					$(container).hide()
					if( callback? )
						callback()
					return
				,delay

		return

	window.showError = (container,message,delay=3000,callback) ->
		_id = $(container).attr('id');
		if typeof _id is 'undefined'
			_id = parseInt(Math.random() * 99999999);
			$(container).attr('id', '_id_' + _id );

		if window.show_server_response_ids[_id]?
			clearTimeout(window.show_server_response_ids[_id]);

		if( $.trim(message) isnt '' )
			$(container).html("<div class='error'>#{message}</div>").show();
			window.show_server_response_ids[_id] = setTimeout ->
					$(container).hide('slide');
					if callback?
						callback();
					return
				,delay

		return

	return
