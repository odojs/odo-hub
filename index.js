const async = require('odo-async')
const template = require('odo-template')

module.exports = (defaultbindings) => {
  const listeners = {}
  const all = []
  const none = []

  const every = (e, cb) => {
    if (listeners[e] == null) listeners[e] = []
    listeners[e].push(cb)
    return {
      off: () => {
        const index = listeners[e].indexOf(cb)
        if (index !== -1) listeners[e].splice(index, 1)
      }
    }
  }
  const once = (e, cb) => {
    const binding = every(e, (payload, callback) => {
      binding.off()
      cb(payload, callback)
    })
    return {
      off: () => { binding.off() }
    }
  }
  if (defaultbindings != null)
    for (let events of defaultbindings)
      every(events, defaultbindings[events])
  const result = {}
  result['new'] = (defaultbindings) => {
    return module.exports(defaultbindings)
  }
  result.child = (defaultbindings) => {
    const res = module.exports()
    res.none((e, description, m, cb) => result.emit(e, m, cb))
    if (defaultbindings != null)
      for (events in defaultbindings)
        res.every(events, defaultbindings[events])
    return res
  }
  result.every = (events, cb) => {
    if (!(events instanceof Array)) events = [events]
    const bindings = events.map((e) => {
      return {
        event: e,
        binding: every(e, cb)
      }
    })
    return {
      off: () => {
        for (let e of bindings) e.binding.off()
      }
    }
  }
  result.once = (events, cb) => {
    if (!(events instanceof Array)) events = [events]
    const count = events.length
    const bindings = events.map((e) => {
      return {
        event: e,
        binding: once(e.event, (m, callback) => {
          count--
          if (count == 0)
            cb(m, callback)
          else
            callback()
        })
      }
    })

    return {
      off: () => {
        for (let e of bindings) e.binding.off()
      }
    }
  }
  result.any = (events, cb) => {
    const bindings = events.map((e) => {
      return { event: e }
    })

    const unbind = () => {
      for (let e of bindings) e.binding.off()
    }

    for (let e of bindings)
      e.binding = once(e.event, () => {
        unbind()
        cb()
      })

    return { off: unbind }
  }
  result.all = (cb) => {
    all.push(cb)
    return {
      off: () => {
        const index = all.indexOf(cb)
        if (index !== -1) all.splice(index, 1)
      }
    }
  }
  result.none = (cb) => {
    none.push(cb)
    return {
      off: () => {
        const index = none.indexOf(cb)
        if (index !== -1) none.splice(index, 1)
      }
    }
  }
  result.emit = (e, m, ecb) => {
    const description = template(e, m)
    const tasks = []
    for (let listener of all)
      ((listener) => {
        tasks.push((cb) => {
          async.delay(() => { listener(e, description, m, cb) })
        })
      })()

    if (listeners[e] != null)
      for (let listener of listeners[e].slice())
        ((listener) => {
          tasks.push((cb) => {
            async.delay(() => { listener(m, cb) })
          })
        })()
    else
      for (let listener of listeners[e].slice())
        ((listener) => {
          tasks.push((cb) => {
            async.delay(() => { listener(e, description, m, cb) })
          })
        })()

    async.parallel(tasks, () => {
      if (ecb != null) ecb()
    })
  }
  return result
}
