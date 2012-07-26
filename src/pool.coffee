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
      proc.output.pipe @output, end: false
      @processes.push proc

  spawn: (callback) ->
    spawn = (proc, cb) ->
      proc.on 'ready', cb
      proc.spawn()
    async.forEach @processes, spawn, callback

  kill: (callback) ->
    kill = (proc, cb) -> proc.kill cb
    async.forEach @processes, kill, callback

  terminate: (callback) ->
    terminate = (proc, cb) -> proc.terminate cb
    async.forEach @processes, terminate, callback

  quit: (callback) ->
    quit = (proc, cb) -> proc.quit cb
    async.forEach @processes, quit, callback

class WebPool extends Pool

exports.createPool = (name, args...) ->
  if name is 'web'
    new WebPool name, args...
  else
    new Pool name, args...
