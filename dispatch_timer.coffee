module.exports = (dispatcher) ->
  _timeout = 1000

  exec: (description, action, cb) ->
    duration = 0
    interval = setInterval ->
      duration += _timeout
      console.log "? #{description} has been running for #{duration / 1000} seconds"
    , _timeout
    dispatcher.exec description, action, ->
      clearInterval interval
      cb() if cb?

  ready: (callback) -> dispatcher.ready callback