async = require 'odo-async'

module.exports = ->
  _queue = []
  _inprogress = no
  _ready = []

  _next = ->
    _inprogress = yes
    # if we've finished the queue we are done
    if _queue.length is 0
      return _inprogress = no if _ready.length is 0
      _queue.push
        description: 'ready'
        action: _ready.shift()
    # pull off the next item and give it a callback
    item = _queue.shift()
    item.action ->
      item.callback() if item.callback?
      async.delay _next

  exec: (description, action, cb) ->
    # add another item to the queue
    _queue.push
      description: description
      action: action
      callback: cb
    # if we aren't running, start running
    async.delay _next if !_inprogress

  ready: (callback) ->
    return callback(->) if !_inprogress
    _ready.push callback