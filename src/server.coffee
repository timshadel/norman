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
      @processes[name].spawn()
    else
      for name, process of @processes
        process.spawn()

exports.createServer = (args...) ->
  new Server args...
