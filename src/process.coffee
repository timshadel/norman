net      = require 'net'

{EventEmitter} = require 'events'
{Monitor}      = require 'forever-monitor'

{LineBuffer, NamedStream}   = require './streams'

class Process extends EventEmitter

  constructor: (@name, @command, options = {}) ->
    @cwd    = options.cwd
    @pad    = options.pad ? 6
    @color  = options.color
    @stdout = new LineBuffer()
    @stderr = new LineBuffer()
    @output = new NamedStream @name, @pad, @color

    @stdout.pipe @output
    @stderr.pipe @output

    @options =
      outFile: true
      errfile: true
      stdout: @stdout
      stderr: @stderr
      silent: true
      __proto__: options

  spawn: (callback) ->
    env = {}
    @options.env = env
    # TODO: load various ENVs?
    for key, value of process.env
      env[key] = value

    env['PORT'] = @port if @port
    env['PS']   = @name

    @child = new Monitor(['/bin/sh', '-c', @command], @options)
    @child.start()

    @spawned(callback)

  spawned: (callback) ->
    callback?()
    @emit 'ready'

  stop: (callback) ->
    if @child
      @child.once 'stop', callback if callback
      @child.stop()
    else
      callback?()


class WebProcess extends Process
  timeout: 30000

  spawn: (callback) ->
    @port = getOpenPort()
    super callback

  spawned: (callback) ->
    tryConnect @port, @timeout, (err) =>
      if err
        @emit 'error', err
      else
        callback?()
        @emit 'ready'


tryConnect = (port, timeout, callback) ->
  decay = 100
  timedOut = false
  timeoutId = setTimeout (-> timedOut = true), timeout

  socket = new net.Socket

  socket.on 'connect', ->
    clearTimeout timeoutId
    socket.destroy()
    callback?()

  socket.on 'error', (err) ->
    if timedOut
      clearTimeout timeoutId
      callback err
    else if err.code is 'ECONNREFUSED'
      setTimeout ->
        socket.connect port
      , decay *= 2
    else
      clearTimeout timeoutId
      callback err

  socket.connect port

getOpenPort = ->
  server = net.createServer()
  server.listen 0
  port = server.address().port
  server.close()
  port

exports.createProcess = (name, args...) ->
  if name.match /^web/
    new WebProcess name, args...
  else
    new Process name, args...
