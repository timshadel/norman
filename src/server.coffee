{readFile} = require 'fs'
{dirname}  = require 'path'

{parseProcfile} = require './procfile'
{createProcess} = require './process'

class Server
  constructor: (@procfile, callback) ->
    @cwd = dirname @procfile

    @processes = {}

    parseProcfile @procfile, (err, procfile) =>
      for name, command of procfile
        @processes[name] = createProcess name, command, @cwd
      callback this

  spawn: (name) ->
    if name
      proc = @processes[name]
      console.error "#{proc.name}.1: #{proc.command}"
      proc.spawn()
      proc.child.stdout.pipe process.stdout, end: false
      proc.child.stderr.pipe process.stderr, end: false

      proc.on 'ready', ->
        console.error "#{proc.name}.1: ready on #{proc.port}"
    else
      for name of @processes
        @spawn name

exports.createServer = (args...) ->
  new Server args...
