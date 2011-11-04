net = require 'net'

{spawn}    = require 'child_process'
{prepend}  = require './util'

class ProcType
  constructor: (@name, @command, @cwd, @appName, @env) ->
    @processes = []
    @nextProcNum = 1
  
  scale: (count) ->
    return if count == @processes.length
    if @processes.length > count
      for [count...@processes.length]
        @kill()
    else
      for [@processes.length...count]
        @spawn()
  
  spawn: ->
    port = getOpenPort()
    name = "#{@name}.#{@nextProcNum++}"
    
    @env['PORT'] = port
    @env['PS']   = name
    
    console.error " norman/#{@appName}[#{name}]: PORT=#{port} `#{@command}`"
    child = spawn '/bin/sh', ['-c', @command], {@env, @cwd}
    
    prepend("    app/#{@appName}[#{name}]: ", child.stdout).pipe process.stdout, end: false
    prepend("    app/#{@appName}[#{name}]: ", child.stderr).pipe process.stderr, end: false
    
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

# Deep copy
# http://coffeescriptcookbook.com/chapters/classes_and_objects/cloning
clone = (obj) ->
  if not obj? or typeof obj isnt 'object'
    return obj

  # process.env has no constructor...
  constructor = obj.constructor ? Object.constructor
  newInstance = new constructor()

  for key of obj
    newInstance[key] = exports.clone obj[key]

  return newInstance


exports.createProcType = (args...) ->
  new ProcType args...
