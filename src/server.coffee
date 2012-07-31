{readFile} = require 'fs'
{dirname}  = require 'path'

{parseProcfile}   = require './procfile'
{createFormation} = require './formation'

class Server
  constructor: (@procfile) ->
    @cwd = dirname @procfile

  spawn: (options = {}, callback = ->) ->
    options.cwd    ?= @cwd
    options.output ?= process.stdout

    parseProcfile @procfile, (err, details) =>
      return callback?(err) if err
      @formation = createFormation details, options
      @formation.spawn callback ? ->

  quit: (callback) ->
    @formation.quit callback

exports.createServer = (args...) ->
  new Server args...
