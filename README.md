# Odo Hub
Publish and subscribe with promises.

```js
import Hub from 'odo-hub'
const hub = Hub()

hub.on('cheese', type => console.log(type))
hub.emit('cheese', 'brie').then(() => console.log('cheese done'))
```

Designed to support component trees with explicit, implicit or no propigation through the use of `hub.child()` or `hub.create()` or passing `hub` as-is.

If an application component needs to use two date pickers the hub passed to these components is likely best created with no implicit propigation by creating a standalone hub through `hub.create()`. Specific events can be handled and new events can be emitted to the parent's hub.

```js
h(datepickercomponent, {
  props: {
    hub: hub.create({
      selectDate: (date) => hub.emit('selectStartDate', date)
    }),
    selectedDate: props.selectedStartDate
  }
}),
h(datepickercomponent, {
  props: {
    hub: hub.create({
      selectDate: (date) => hub.emit('selectEndDate', date)
    }),
    selectedDate: props.selectedEndDate
  }
})
```

In some situations all events created within a child component can be implicitly propigated except for specific events. This is useful for when additional information is added to a child component's event, or if an event needs to be ignored.

```js
h(datepickercomponent, {
  props: {
    hub: hub.child({
      selectDate: ({date}) => hub.emit('selectDate', {
        date,
        whenSelected: Date.now()
      }),
      cancel: () => {} // ignore cancel
      // all other events implicitly propigated via unhandled
    })
  }
})
```

## constructor Hub(initial)

The hub constructor takes an optional object of event names to functions as initial listeners.

```js
const hub = Hub({
  event1: (payload1) => console.log(payload1),
  event2: (payload2) => console.log(payload2)
})
```

## hub.on(event, fn)

Register an event listener. Uses promises. fn has signature (args...)

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
hub.emit('new person', 'Bob', 'bob@hotmail.com')
```

## hub.unhandled(fn)

Register a listener for any events that are unhandled (have no listeners). Uses promises. fn has signature (event, args...)

```js
hub.on('cheese', () => console.log('cheese!'))
hub.unhandled((event, ...args) => {
  console.log('unknown event', event)
})
hub.emit('cheese') // cheese!
hub.emit('bread') // unknown event bread
```

## hub.unhandledOff(fn)

Unregister an unhandled event listener.

```js
const unhandled = (event, ...args) => {
  console.log('unknown event', event)
}
hub.on('cheese', () => console.log('cheese!'))
hub.unhandled(unhandled)
hub.emit('cheese') // cheese!
hub.emit('bread') // unknown event bread
hub.unhandledOff(unhandled)
hub.emit('bread') // <nothing>
```

## hub.child(initial)

Creates a child hub where all events unhandled by listeners on the child are propigated up to the parent (current) hub. Takes an optional object of event names to functions as initial listeners.

```js
hub.on('cheese', () => console.log('cheese!'))
hub.on('bread', () => console.log('bread!'))
const child = hub.child()
child.on('bread', () => console.log('gluten free'))

hub.emit('bread') // bread!
hub.emit('cheese') // cheese!
child.emit('bread') // gluten free
child.emit('cheese') // cheese!
```

## hub.create(initial)

Creates a new hub disconnected from the current hub. This is equivalent to the Hub() constructor but can be called on any hub instance. Takes an optional object of event names to functions as initial listeners.

```js
hub.on('cheese', () => console.log('cheese!'))
hub.on('bread', () => console.log('bread!'))
const child = hub.create()
child.on('bread', () => console.log('gluten free'))

hub.emit('bread') // bread!
hub.emit('cheese') // cheese!
child.emit('bread') // gluten free
child.emit('cheese') // <nothing>
```
