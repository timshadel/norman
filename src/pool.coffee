{createProcess} = require './process'

{EventEmitter}     = require 'events'
{ForwardingStream} = require './streams'

async = require 'async'

class Pool extends EventEmitter

  constructor: (@name, @command, options = {}) ->
    @concurrency = options.concurrency ? 1
    @output = new ForwardingStream

    @processes = []
    for instance in [1..@concurrency]
      proc = createProcess "#{@name}.#{instance}", @command, options
      proc.out.pipe @output, end: false
      @processes.push proc

  spawn: (callback) ->
    spawn = (process, cb) ->
      process.on 'ready', cb
      process.spawn()
    async.forEach @processes, spawn, callback

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
