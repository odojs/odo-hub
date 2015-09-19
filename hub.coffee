async = require 'odo-async'
template = require 'odo-template'

module.exports = (dispatcher) ->
  listeners = {}
  all = []

  every = (e, cb) ->
    listeners[e] = [] if !listeners[e]?
    listeners[e].push cb

    off: ->
      index = listeners[e].indexOf cb
      if index isnt -1
        listeners[e].splice index, 1

  once = (e, cb) ->
    binding = every e, (payload, callback) ->
      binding.off()
      cb payload, callback
    off: -> binding.off()

  # Subscribe to an event
  every: (events, cb) ->
    events = [events] unless events instanceof Array
    bindings = for e in events
      event: e

    for e in bindings
      e.binding = every e.event, cb

    off: -> e.binding.off() for e in bindings

  once: (events, cb) ->
    events = [events] unless events instanceof Array
    count = 0
    bindings = for e in events
      count++
      event: e
      complete: no

    for e in bindings
      e.binding = once e.event, (m, callback) ->
        count--
        e.complete = yes
        if count is 0
          cb(m, callback)
        else
          callback()

    off: -> e.binding.off() for e in bindings

  any: (events, cb) ->
    bindings = for e in events
      event: e

    unbind = -> e.binding.off() for e in bindings

    for e in bindings
      e.binding = once e.event, ->
        unbind()
        cb()

    off: unbind

  all: (cb) ->
    all.push cb
    off: ->
      index = all.indexOf cb
      if index isnt -1
        all.splice index, 1

  # Publish an event
  emit: (e, m, ecb) ->
    description = "#{template e, m}"

    tasks = []
    for listener in all
      do (listener) ->
        tasks.push (pcb) ->
          dispatcher.exec description, (scb) ->
            listener e, description, m, ->
              pcb()
              scb()
    if listeners[e]?
      for listener in listeners[e].slice()
        do (listener) ->
          tasks.push (pcb) ->
            dispatcher.exec description, (scb) ->
              listener m, ->
                pcb()
                scb()

    async.parallel tasks, -> ecb() if ecb?

  ready: (cb) -> dispatcher.ready cb