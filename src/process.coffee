net = require 'net'

{spawn} = require 'child_process'

class Process
  constructor: (@name, @command, @cwd) ->

  spawn: ->
    @port = getOpenPort()

    env = {}
    for key, value of process.env
      env[key] = value

    env['PORT'] = @port
    env['PS']   = "#{@name}.1"

    @child = spawn '/bin/sh', ['-c', @command], {env, @cwd}

    @child.stdout.pipe process.stdout, end: false
    @child.stderr.pipe process.stderr, end: false

getOpenPort = ->
  server = net.createServer()
  server.listen 0
  port = server.address().port
  server.close()
  port

exports.createProcess = (args...) ->
  new Process args...
