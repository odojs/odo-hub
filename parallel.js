// Generated by CoffeeScript 1.9.2
var hub, parallel, timer;

parallel = require('./dispatch_parallel');

timer = require('./dispatch_timer');

hub = require('./hub');

module.exports = hub(timer(parallel()));