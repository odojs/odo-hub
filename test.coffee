hub = require './parallel'
hub.every 'thing', (e, cb) ->
  console.log e
  cb()


hub.emit 'thing', 'weeee', ->
  hub.emit 'thing', 'weeee2', ->
    console.log 'done.'