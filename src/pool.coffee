{createProcess} = require './process'

{EventEmitter} = require 'events'

async = require 'async'

class Pool extends EventEmitter
  constructor: (@name, @command, options = {}) ->
    @concurrency = options.concurrency ? 1

    @processes = []
    for instance in [1..@concurrency]
      @processes.push createProcess "#{@name}.#{instance}", @command, options

  spawn: ->
    for process in @processes
      process.spawn()
      @emit 'process:spawn', process

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
