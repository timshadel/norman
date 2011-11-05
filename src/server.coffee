{readFile} = require 'fs'
{dirname}  = require 'path'

{parseProcfile} = require './procfile'
{createPool}    = require './pool'

class Server
  constructor: (@procfile, callback) ->
    @cwd = dirname @procfile

    @pools = {}

    parseProcfile @procfile, (err, procfile) =>
      for name, command of procfile
        @pools[name] = createPool name, command, cwd: @cwd
      callback this

  spawn: ->
    for name, pool of @pools
      pool.on 'process:spawn', (proc) ->
        console.error "#{proc.name}: #{proc.command}"
        proc.child.stdout.pipe process.stdout, end: false
        proc.child.stderr.pipe process.stderr, end: false

        proc.on 'ready', ->
          console.error "#{proc.name}: ready on #{proc.port}"

      pool.spawn()

exports.createServer = (args...) ->
  new Server args...
