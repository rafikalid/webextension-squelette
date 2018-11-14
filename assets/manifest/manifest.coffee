###*
 * Extension manifest
 * @type {[type]}
###
name: '__MSG_extName__' # get name from locals, do not change this
version: '0.0.1'
description: '__MSG_extDescription__'
homepage_url: 'https://brsolab.com/extName'
# icon:
# 	'16': 'icons/16.png'
# 	'48': 'icons/48.png'
# 	'128': 'icons/128.png'

# general
manifest_version: 2
# when firefox
<% if(nav == 'firefox'){ %>
applications:
	gecko:
		id: 'contact@brsolab.com'
		strict_min_version: '47.0'
		# strict_max_version: '57.*'
<% } %>

# Default local
default_locale: 'en'

# background
background:
	page: 'background/main.html' # use page to resolve bug with firefox

# browser_action
browser_action:
	# default_icon: 'icons/19.png'
	default_title: 'Extension title'
	default_popup: 'popup/main.html'

# Permissions
permissions: [
	# "cookies"
	# "webRequest"
	# "webRequestBlocking"
	# "contextMenus"
	# "tabs"
	# "activeTab"
	# "<all_urls>"
	# "notifications"
	# "bookmarks"
	# "downloads"
	# "clipboardRead"
	# "webNavigation"

	# chrome et opera
	<% if(nav == 'chrome' || nav == 'opera'){ %>
	# 'tabCapture'
	# 'clipboardWrite'
	# 'clipboardRead'
	<% } %>
]

# resources that are accessible outside the extension
# useful to show images inside webpages
web_accessible_resources:[
	# '/content-script/main.htm'
	# 'path/to/some/image'
]

###*
 * Content script
###
# content_scripts: [
# 		# document start
# 		matches: ['<all_urls>']
# 		js: [
# 			'/lib/browser-polyfill.min.js'
# 			'/js/commons/utils.js'
# 			'/js/commons/message-emitter.js'
# 			'js.js'
# 		]
# 		all_frames: true
# 		run_at: 'document_start'
# 	,
# 		run_at: 'document_end'
# ]