Sequencer = require 'odo-sequencer'
async = require 'odo-async'
template = require 'odo-template'

bind = ->
  # Simple publish and subscribe
  # Publish is async
  class Hub
    constructor: ->
      @_listeners = {}
      @_all = []
      @_seq = new Sequencer()

    create: -> new Hub()

    _every: (e, cb) =>
      @_listeners[e] = [] if !@_listeners[e]?
      @_listeners[e].push cb

      off: =>
        index = @_listeners[e].indexOf cb
        if index isnt -1
          @_listeners[e].splice index, 1

    # Subscribe to an event
    every: (events, cb) =>
      events = [events] unless events instanceof Array
      bindings = for e in events
        event: e

      for e in bindings
        e.binding = @_every e.event, cb

      off: => e.binding.off() for e in bindings

    _once: (e, cb) =>
      binding = @every e, (payload, callback) =>
        binding.off()
        cb payload, callback
      off: -> binding.off()

    once: (events, cb) =>
      events = [events] unless events instanceof Array
      count = 0
      bindings = for e in events
        count++
        event: e
        complete: no

      for e in bindings
        e.binding = @_once e.event, (m, callback) ->
          count--
          e.complete = yes
          if count is 0
            cb(m, callback)
          else
            callback()

      off: -> e.binding.off() for e in bindings

    any: (events, cb) =>
      bindings = for e in events
        event: e

      unbind = -> e.binding.off() for e in bindings

      for e in bindings
        e.binding = @_once e.event, ->
          unbind()
          cb()

      off: unbind

    all: (cb) =>
      @_all.push cb
      off: ->
        index = @_all.indexOf cb
        if index isnt -1
          @_all.splice index, 1

    # Publish an event
    emit: (e, m, ecb) =>
      description = "#{template e, m}"

      tasks = []
      for listener in @_all
        do (listener) =>
          tasks.push (pcb) =>
            @_seq.exec description, (scb) ->
              listener e, description, m, ->
                pcb()
                scb()
      if @_listeners[e]?
        for listener in @_listeners[e].slice()
          do (listener) =>
            tasks.push (pcb) =>
              @_seq.exec description, (scb) ->
                listener m, ->
                  pcb()
                  scb()

      async.parallel tasks, -> ecb() if ecb?

    ready: (cb) =>
      @_seq.ready cb

  new Hub()

module.exports = bind()