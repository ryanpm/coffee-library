do () ->
	window.jsValidate = (options) ->
		defaults = {
			form: null
			on: null
			error_container:null
			disable_validate_if: false
		}
		options = $.extend({},defaults,options);

		valid = true
		if options.form is null or typeof options.form == 'undefined'
			return true

		$('.validate',options.form).each ->
			return if !valid

			label = $(this).attr('data-label') or $(this).attr('name')
			validate_if_not_empty = $(this).attr('data-validate-if')
			validate_on = $(this).attr('data-validate-on');

			value = $.trim($(this).val())

			#check the on rule
			if( options.on isnt null )
				if validate_on?
					did_matched = false;
					on_allowed =  validate_on.split('.')
					on_allowed.map (i,e) ->
							if( i.toLowerCase() == options.on.toLowerCase() && !did_matched  )
								did_matched = true;
							return
					# no matched? then skip this then move to next
					if( !did_matched )
						return


			if( value is '' )

				#check if validation is conditional
				if (typeof validate_if_not_empty is 'undefined' or options.disable_validate_if)
					showError( options.error_container, label+' must not be empty',60000)
					valid = false

			else
				if( $(this).attr('type') is 'file' )
					filesize_limit  = $(this).attr('data-valid-maxsize')
					if  filesize_limit?

						if (window.FileReader)
							input = $(this).get(0)
							if  input?
								file = input.files[0]
								if( (file.size / 1024 / 1024) >  filesize_limit )
									showError(options.error_container, "#{label} is more than #{filesize_limit}MB.",60000)
									valid = false

					_a_ext = $(this).attr('data-valid-ext');
					_a_valid_image = $(this).attr('data-valid-image');
					if( _a_ext? or _a_valid_image? )
						did_matched = false
						if( _a_ext? )
							allowed_ext = $(this).attr('data-valid-ext').split(',')
						else
							allowed_ext = ['jpg','jpeg','png','gif'];

						val_parts =  value.split('.')
						i_ext = val_parts[ val_parts.length - 1  ]

						allowed_ext.map (i,e) ->
							if( i.toLowerCase() == i_ext.toLowerCase() && !did_matched  )
								did_matched = true;
							return

						if(!did_matched)
							_ext_joined = allowed_ext.join(', ');
							showError( options.error_container ,  "#{label} accepts file type with #{_ext_joined}.",60000);
							valid = false;

			return
		return valid
	return
