net = require 'net'

{EventEmitter} = require 'events'
{spawn} = require 'child_process'

class Process extends EventEmitter
  constructor: (@name, @command, options = {}) ->
    @cwd = options.cwd

  spawn: ->
    env = {}
    for key, value of process.env
      env[key] = value

    env['PORT'] = @port if @port
    env['PS']   = "#{@name}.1"

    @child = spawn '/bin/sh', ['-c', @command], {env, @cwd}

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
