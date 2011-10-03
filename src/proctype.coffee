net = require 'net'

{spawn} = require 'child_process'
{clone} = require './util'

class ProcType
  constructor: (@name, @command, @cwd, env) ->
    @processes = []
    @nextProcNum = 1
    @env = clone env

  scale: (count) ->
    return if count == @processes.length
    if @processes.length > count
      for [count...@processes.length]
        kill()
    else
      for [@processes.length...count]
        spawn()

  spawn: ->
    port = getOpenPort()
    name = "#{@name}.#{@nextProcNum++}"

    env = clone @env

    env['PORT'] = port
    env['PS']   = name

    console.error "#{name} (#{port}): #{@command}"
    child = spawn '/bin/sh', ['-c', @command], {env, @cwd}

    child.stdout.pipe process.stdout, end: false
    child.stderr.pipe process.stderr, end: false

    @processes.push
      child: child
      port:  port
      name:  name

getOpenPort = ->
  server = net.createServer()
  server.listen 0
  port = server.address().port
  server.close()
  port

exports.createProcType = (args...) ->
  new ProcType args...
