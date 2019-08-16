# Odo Hub
Simple pub sub with promises

```js
import Hub from 'odo-hub'
const hub = Hub()

hub.on('cheese', type => console.log(type))
hub.emit('cheese', 'brie').then(() => console.log('cheese done'))
```

## Constructor

The hub constructor takes an optional object of event names to functions as initial listeners.

```js
const hub = Hub({
  event1: (payload1) => console.log(payload1),
  event2: (payload2) => console.log(payload2)
})
```

## hub.on(event, fn)

Register an event listener. Uses promises. fn has signature (event, args...)

```js
hub.on('cheese', (type) => console.log(type))

hub.on('cheese', (type) => {
  console.log(type)
  return axios.get('/cheese').then((res) => {
    console.log(res)
  })
})
```

## hub.off(event, fn)

Unregister an event listener.

```js
const fn = (type) => console.log('got cheese', type)
hub.on('cheese', fn)
hub.off('cheese', fn)
```

## hub.emit(event, args...)

Emit an event. Uses promises.

```js
hub.emit('cheese', 'brie')
  .then(() => console.log('cheese done'))
hub.emit('')
```

