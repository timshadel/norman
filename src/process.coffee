net      = require 'net'
color    = require("ansi-color").set
strftime = require 'strftime'
sprintf  = require('sprintf').sprintf

{EventEmitter} = require 'events'
{spawn}        = require 'child_process'

{LineBuffer, PrependingBuffer}   = require './streams'

class Process extends EventEmitter

  constructor: (@name, @command, options = {}) ->
    @cwd   = options.cwd
    @pad   = options.pad ? 6
    @color = options.color

    format = "%-#{@pad}s"
    message = "#{strftime("%H:%M:%S")} #{sprintf(format, @name)} | "
    message = color(message, @color) if @color?
    @out = new PrependingBuffer message

  spawn: ->
    env = {}
    for key, value of process.env
      env[key] = value

    env['PORT'] = @port if @port
    env['PS']   = @name

    @child = spawn '/bin/sh', ['-c', @command], {env, @cwd, stdio: 'pipe'}
    @child.stdout.pipe(new LineBuffer()).pipe @out
    @child.stderr.pipe(new LineBuffer()).pipe @out

    @spawned()

  spawned: ->
    @emit 'ready'

  kill: (callback) ->
    if @child
      @child.once 'exit', callback if callback
      @child.kill 'SIGKILL'
    else
      callback?()

  terminate: (callback) ->
    if @child
      @child.once 'exit', callback if callback
      @child.kill 'SIGTERM'
    else
      callback?()

  quit: (callback) ->
    if @child
      @child.once 'exit', callback if callback
      @child.kill 'SIGQUIT'
    else
      callback?()

class WebProcess extends Process
  timeout: 30000

  spawn: ->
    @port = getOpenPort()
    super

  spawned: ->
    tryConnect @port, @timeout, (err) =>
      if err
        @emit 'error', err
      else
        @emit 'ready'


tryConnect = (port, timeout, callback) ->
  decay = 100
  timedOut = false
  timeoutId = setTimeout (-> timedOut = true), timeout

  socket = new net.Socket

  socket.on 'connect', ->
    clearTimeout timeoutId
    socket.destroy()
    callback()

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
