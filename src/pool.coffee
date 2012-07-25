{createProcess} = require './process'

{EventEmitter}     = require 'events'
{ForwardingStream} = require './streams'

async = require 'async'

class Pool extends EventEmitter

  constructor: (@name, @command, options = {}) ->
    @concurrency = options.concurrency ? 1
    @out = new ForwardingStream

    @processes = []
    for instance in [1..@concurrency]
      proc = createProcess "#{@name}.#{instance}", @command, options
      proc.on 'ready', =>
        proc.out.pipe @out, end: false
      @processes.push proc

  spawn: ->
    waiting = []
    spawned = false
    for process in @processes
      waiting.push process
      process.on 'ready', ->
        index = waiting.indexOf(process)
        waiting.splice(index, 1)
        @emit 'pool:ready' if spawned and waiting.length is 0
        
      process.spawn()
      @emit 'process:spawn', process

    spawned = true
    @emit 'pool:ready' if waiting.length is 0

  kill: (callback) ->
    kill = (process, cb) -> process.kill cb
    async.forEach @processes, kill, callback

  terminate: (callback) ->
    terminate = (process, cb) -> process.terminate cb
    async.forEach @processes, terminate, callback

  quit: (callback) ->
    quit = (process, cb) -> process.quit cb
    async.forEach @processes, quit, callback

class WebPool extends Pool

exports.createPool = (name, args...) ->
  if name is 'web'
    new WebPool name, args...
  else
    new Pool name, args...
