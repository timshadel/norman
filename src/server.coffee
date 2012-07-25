{readFile} = require 'fs'
{dirname}  = require 'path'

{parseProcfile}   = require './procfile'
{createFormation} = require './formation'

class Server
  constructor: (@procfile, callback) ->
    @cwd = dirname @procfile

    parseProcfile @procfile, (err, details) =>
      return callback(err) if err
      @formation = createFormation details, {@cwd}
      @formation.out.pipe process.stdout, end: true
      @formation.spawn()
      callback

exports.createServer = (args...) ->
  new Server args...
