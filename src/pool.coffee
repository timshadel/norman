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

  stop: (callback) ->
    stop = (proc, cb) -> proc.stop cb
    async.forEach @processes, stop, callback


class WebPool extends Pool

exports.createPool = (name, args...) ->
  if name is 'web'
    new WebPool name, args...
  else
    new Pool name, args...
