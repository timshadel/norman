net = require 'net'

{spawn} = require 'child_process'

class Process
  constructor: (@name, @command, @cwd) ->

  spawn: ->
    env = {}
    for key, value of process.env
      env[key] = value

    env['PORT'] = @port if @port
    env['PS']   = "#{@name}.1"

    console.error "#{@name}.1: #{@command}"
    @child = spawn '/bin/sh', ['-c', @command], {env, @cwd}

    @child.stdout.pipe process.stdout, end: false
    @child.stderr.pipe process.stderr, end: false

class WebProcess extends Process
  spawn: ->
    @port = getOpenPort()

    super

getOpenPort = ->
  server = net.createServer()
  server.listen 0
  port = server.address().port
  server.close()
  port

exports.createProcess = (name, args...) ->
  if name is 'web'
    new WebProcess name, args...
  else
    new Process name, args...
