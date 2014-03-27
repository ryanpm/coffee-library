
do () ->

	options = {
			loader_img: null
			id: null
			html: null
			container: null
			action : null
			page: null
			data: null
			load: true
			callback: null
		}

	_url = () ->
		_post_data = post_data();
		__url = if( _post_data is null || _post_data is '' ) then '?' else "?#{_post_data}&"
		return "#{__url}page=#{ap_current_page[ options.id]}"

	setLinks = (response) ->
		options = $.extend({},options,{load:true})
		$(options.container).find('.pagination a.gotopage').click () ->
			ap_current_page[ options.id] =  parseInt($(this).attr('data-page'))
			page(ap_current_page[ options.id])
			return false
		$(options.container).find('.pagination a.page_back, .arrow_prev').click () ->
            prev()
            return false
        $(options.container).find('.pagination a.page_next, .arrow_next').click () ->
            next()
            return false
        if(options.callback isnt null)
            options.callback({pagenum:ap_current_page[ options.id]})
        #serverProcessing(false)
		return

	loadPage = () ->
		if options.loader_img?
			w = $(options.container).width()
			h = $(options.container).height()
			cw = (w/2)-30
			ch = (h/2)-30
			#serverProcessing(true)
		loadServerContent( options.container,  "#{options.action}#{_url()}" , setLinks);
		isloaded = true;

		return

	page = (_newpage) ->
		options = $.extend({},options,{load:true,page:_newpage})
		loadPage()
		return

	prev = () ->
		ap_current_page[ options.id]--
		page(ap_current_page[ options.id])
		return

	next = () ->
		ap_current_page[ options.id]++
		page(ap_current_page[ options.id])
		return

	load = (callback) ->
		page(1)
		if( typeof callback != 'undefined' )
			callback()
		return

	fn_isloaded = ()-> isloaded
	post_data = ()->
		if( typeof options.data == "function" ) then options.data() else options.data

	currentPage = () -> ap_current_page[options.id]

	window.ap_current_page = {}
	window.ajaxPagination = (page, _options) ->

		options = $.extend({},options,_options);
		if(options.load is null)
			options.load = true

		if( typeof ap_current_page[options.id] is 'undefined' )
			ap_current_page[options.id] = 1
		_id = options.id

		isloaded = false

		if( options.load  )
			if( options.html isnt null )
				$(options.container).html(options.html)
				setLinks()
			else
				loadPage()
		else
			setLinks(null)


		return {
            refresh:loadPage
            page:page
            next:next
            prev:prev
            options:options
            isloaded:fn_isloaded
            load:load
            post_data:post_data
            currentPage:currentPage
        }

	return