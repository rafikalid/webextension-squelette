###*
 * Extension locals
 *
 * @html_format
 * to add i18n to HTML file, use attributes:
 * 	* i18n-text="msgKey": replace innerHTML with this text
 * 	* add an attribute
 * 	* i18n="attrName:msgKey"
 * 	* i18n="title:msgKey"
 * 	* i18n="placeholder:msgKey"
 * 	* i18n="value:msgKey"
 * @predefined_messages
 * 
###

# global locals
# When the same name apply to all languages
extName: 'Extension Name'

# extension description
extDescription:
	en: 'ext description'
	fr: 'Description de l\'extension'

messageKey:
	en: 'Message in english'
	fr: 'Message en français'
	# 'fr_FR': 'Message en français france'

message2key:
	en:
		message: 'Message2 in english with $varHolder$'
		placeholders:
			varHolder:
				content: 'test $1'
				example: 'test brsolab'
	fr: 'juste ne pas avoir erreur que fr est manquante'
