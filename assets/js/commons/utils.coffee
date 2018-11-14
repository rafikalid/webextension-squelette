###*
 * set errors to be serializable
###
do ->
	oldToJSON = Error.prototype.toJSON
	Object.defineProperty Error.prototype, 'toJSON',
		configurable: true
		writable: true
		value: ->
			# call old toJSON
			if oldToJSON
				err = oldToJSON.call this
				return unless err
			else
				err = this
			# serialize
			result = Object.create null
			result.message = err.message
			result.stack = err.stack
			# add user define attributes if exists
			for attr in Object.keys err
				result[attr] = err[attr]
			return result
	# end
	return