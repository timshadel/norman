{readFile} = require 'fs'
{dirname}  = require 'path'

{parseProcfile}   = require './procfile'
{createFormation} = require './formation'

class Server
  constructor: (@procfile) ->
    @cwd = dirname @procfile

  spawn: (callback = ->) ->
    parseProcfile @procfile, (err, details) =>
      return callback(err) if err
      @formation = createFormation details, {@cwd, output: process.stdout}
      @formation.spawn callback

exports.createServer = (args...) ->
  new Server args...
