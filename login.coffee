
do () ->

	window.modLoginFunctions = {}
	window.modLogin = (callback) ->
		_id = parseInt(Math.random()*99999999)

		window.modLoginFunctions['submit_'+_id] = ->
			dlg_username = $('#dlg_username_'+ _id ).val()
			dlg_password = $('#dlg_password_'+ _id ).val()

			serverProcess {
				action:'user/auth'
				data:'login=1&user_username='+dlg_username+'&user_password='+dlg_password
				callback: (json) ->

					$('#dlg_login_error_'+_id).html('<div class="error">'+json.html_error+'</div>')
					if( json.success )
						window.is_guest = false

						$('._log_hide').hide()
						$('._log_show').show()
						$('._log_enable').attr('disabled',false)
						$('._log_fullname').html( json.welcome_name )

						closeColorBox()
						try	callback()

					else  if(json.html_error isnt null)
						$('#dlg_login_error_'+_id).html('<div class="error">'+json.html_error+'</div>')


					return

			}
			return

		window.modLoginFunctions['cancel_'+_id] = ->
			closeColorBox()
			return
		openColorBox {
			html:"<div><div style='background:#ee1f37;padding:5px'><h4 style='padding:0px;margin:0px'>Please Login</h4></div>  <div style='padding:10px;height:60px' ><div id='dlg_login_error_#{_id}' style='height:35px'></div><div style='padding:7px'><div class='left'  style='width:80px'>Username:</div> <div class='input left'><img src='#{urlbase}images/bg_input01.png' class='left'><input  id='dlg_username_#{_id}' type='text' style='width:250px;' class='left' /><img src='#{urlbase}images/bg_input02.png' class='left'></div> </div> <div style='clear:both'></div> <div style='padding:7px'><div class='left' style='width:80px'>Password:</div> <div class='input left'><img src='#{urlbase}images/bg_input01.png' class='left'><input  id='dlg_password_#{_id}' type='password' style='width:250px;' class='left' /><img src='#{urlbase}images/bg_input02.png' class='left'></div></div> </div><div style='text-align:right;padding:5px;white-space: nowrap;clear: both;padding-top: 10px;padding-right: 28px;'><input type='button' onclick='modLoginFunctions.submit_#{_id}(this); ' value='   Submit   '  class='btn_red02' style='cursor:pointer'><input type='button' onclick='modLoginFunctions.cancel_#{_id}(); ' value='   Cancel   ' class='btn_red02' style='cursor:pointer;margin-left:10px'></div></div>",
			transition:'none',
			height:'220px',
			width:'400px',
			fixed:true,
			title:false,
			closeButton:false
		}
		return

	window.modLoginStatusUpdate = (status) ->
		if( status )
			window.is_guest = true
			$('._log_hide').show()
			$('._log_show').hide()
			$('._log_enable').attr('disabled',true)
		else
			window.is_guest = true
			$('._log_hide').show()
			$('._log_show').hide()
			$('._log_enable').attr('disabled',true)

		return

	window.modLogout = () ->
		window.modLoginStatusUpdate(false)
		return

	return