{createProcess} = require './process'

{EventEmitter}     = require 'events'
{ForwardingStream} = require './streams'

async = require 'async'
call  = require './call'

class Pool extends EventEmitter

  constructor: (@name, @command, options = {}) ->
    @processes = [1..(options.concurrency ? 1)].map (instance) => createProcess "#{@name}.#{instance}", @command, options

  spawn: (callback) ->
    async.forEach @processes, call("spawn"), callback

  stop: (callback) ->
    async.forEach @processes, call("stop"), callback


class WebPool extends Pool

exports.createPool = (name, args...) ->
  if name is 'web'
    new WebPool name, args...
  else
    new Pool name, args...
