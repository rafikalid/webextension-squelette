###*
 * Mesage emitter
###
"use strict"

MsgEmitter = new class MsgEmitter
	constructor: ->
		@_listeners = Object.create null
		# add listener to chrome messages
		browser.runtime.onMessage.addListener (msg, sender)=>
			eventName = msg.eventName
			errResult = result = undefined
			if eventName and (queue = @_listeners[eventName])
				jobs = []
				queue.forEach (listener)->
					try
						v = listener msg.data, sender
						if v instanceof Promise
							jobs.push v.then (r)->
								result = r
								return
						else unless v is undefined
							result = v
					catch err
						errResult = err
				# wait for all event listeners to finish
				if jobs.length
					return Promise.all(jobs)
						.catch (err)-> errResult = err
						.then ->
							data: result
							err	: errResult
				else if errResult
					return Promise.resolve err: errResult
				else unless result is undefined
					return Promise.resolve data: result, err: null
	###*
	 * add event listener
	 * @param  {String} eventName - name of the event
	 * @param  {function} listener  - event listener
	###
	on: (eventName, listener)->
		# test
		throw new Error 'Illegal arguments' unless arguments.length is 2
		throw new Error 'EventName expected string or symbol' unless typeof eventName is 'string' or typeof eventName is 'symbol' # for performance porpose, we didn't use in []
		throw new Error 'listener expected function' unless typeof listener is 'function'
		# process
		queue = @_listeners[eventName] ?= new Set()
		queue.add listener
		# chain
		this
	###*
	 * Add event listener to listen only once
	###
	once: (eventName, listener)->
		# wrapper
		wrapFx = (event) =>
			# call listener
			listener event
			# remove wrapper
			@off eventName, wrapFx
			return
		# add
		@on eventName, wrapFx
	###*
	 * remove event listener
	 * @param  {String or Symbol} eventName - event name
	 * @optional @param  {function} listener  - listener to remove
	 * @return {[type]}           [description]
	###
	off: (eventName, listener)->
		throw new Error 'EventName expected string or symbol' unless typeof eventName is 'string' or typeof eventName is 'symbol' # for performance porpose, we didn't use in []
		
		queue = @_listeners[eventName]
		if queue then switch arguments.length
			when 2
				throw new Error 'listener expected function' unless typeof listener is 'function'
				# remove listener from array
				queue.delete listener
			when 1
				# remove all listeners
				queue.clear()
				delete @_listeners[eventName]
			else
				throw new Error 'Illegal arguments'
		# chain
		this
	###*
	 * Emit event
	 * @param {String} eventName - name of the event
	 * @param {Plain object} eventData - serialisable object
	 * @example
	 * .emit 'eventName', {data}
	 * .emit tabId, 'eventName', data
	###
	emit: (tabId, eventName, eventData)->
		switch arguments.length
			when 2
				[tabId, eventName, eventData] = [null, tabId, eventName]
			when 3
			else
				throw new Error 'Illegal arguments'
		# return promise
		return browser.runtime.sendMessage tabId,
				eventName: eventName
				data: eventData
			.then (data)->
				unless data
					return
				else if data.err
					Promise.reject data.err
				else
					return data.data