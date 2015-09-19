async = require 'odo-async'

module.exports = ->
  exec: (description, action, cb) ->
    async.delay ->
      action ->
        cb() if cb?

  # born ready
  ready: (cb) -> cb ->