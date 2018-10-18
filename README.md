# Odo Hub
Simple pub sub with promises

```js
const hub = require('odo-hub')();

hub.on('cheese', type => console.log(type))
hub.emit('cheese', 'brie')
```
