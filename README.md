# Odo Hub
Simple pub sub with promises

```js
import Hub from 'odo-hub'
const hub = Hub()

hub.on('cheese', type => console.log(type))
hub.emit('cheese', 'brie').then(() => console.log('cheese done'))
```

## constructor
```js
import Hub from 'odo-hub'
// Constructor takes an optional object of event names to functions as initial listeners
const hub = Hub({
  event1: (payload1) => console.log(payload1),
  event2: (payload2) => console.log(payload2)
})
````
