###*
 * i18n for HTML files
 * @example
 * <div i18n-text="msgKey"></div>
 * <input i18n="{placeholder:msgKey}" />
 * <input i18n="{placeholder:'msgKey', value: 'valueKey'}" />
 *
 * ou plus simple avec pug
 * div(i18n-text="msgKey")
 * input(i18n={placeholder:'msgKey'})
 * input(i18n={placeholder:'msgKey', value:'valueKey'})
###

htmlParseI18n = (container)->
	container ?= document
	# replace all text message
	for element in container.querySelectorAll '[i18n-text]'
		element.innerText = browser.i18n.getMessage element.getAttribute 'i18n-text'
	# replace other attributes
	for element in container.querySelectorAll '[i18n]'
		try
			for k,v of JSON.parse element.getAttribute 'i18n'
				element.setAttribute k, browser.i18n.getMessage v
		catch e
			console.error 'i18n>> ', e
	# ends
	return

# apply this parser when this page is load
# This file shoud be included in the bottom of the html file
do htmlParseI18n
