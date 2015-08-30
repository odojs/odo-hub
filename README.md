# Odo Hub
Simple pub sub.

# Notes
- Subscribers are required to callback to continue processing
- 

```js
var hub = require('odo-hub');

var hellosub = hub.every('hello {person}', function(p, cb) {
  console.log(p.person);
  cb();
});

hub.once('hello {person}', function(p, cb) {
  console.log('Once ' + p.person);
  cb();
});

hub.all(function(e, description, p, cb) {
  console.log(description);
  cb();
});

hub.emit('hello {person}', { person: 'Frank' });
hub.emit('hello {person}', { person: 'Bob' });
hellosub.off();
hub.emit('hello {person}', { person: 'Dave' }, function() {
  console.log('Finished all events');
});
```
