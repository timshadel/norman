{createProcess} = require './process'

{EventEmitter}     = require 'events'
{ForwardingStream} = require './streams'

async = require 'async'
call  = require './call'

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
    async.forEach @processes, call("spawn"), callback

  stop: (callback) ->
    async.forEach @processes, call("stop"), =>
      @output.end()
      callback?()


class WebPool extends Pool

exports.createPool = (name, args...) ->
  if name is 'web'
    new WebPool name, args...
  else
    new Pool name, args...
