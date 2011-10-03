{readFile}  = require 'fs'
path        = require 'path'

{createProcType} = require './proctype'
{clone}          = require './util'

class Formation
  constructor: (@procfile, callback) ->
    @cwd = path.dirname @procfile
    envPath = path.join(@cwd, '.env')

    @proctypes = {}
    @env = clone process.env

    readEnvFile = (next) =>
      readFile envPath, 'utf-8', (err, data) =>
        for line in data.split "\n"
          [name, value] = line.split /\s*=\s+/, 2
          continue if name is ''
          @env[name] = value
        next()

    readProcfile = (next) =>
      readFile @procfile, 'utf-8', (err, data) =>
        for line in data.split "\n"
          [name, command] = line.split /\s*:\s+/, 2
          continue if name is ''
          @proctypes[name] = createProcType name, command, @cwd, @env
        next()

    path.exists envPath, (exists) =>
      if exists
        readEnvFile readProcfile callback(this)
      else
        readProcfile callback(this)

  scale: (concurrency = 'web=1') ->
    for pair in concurrency.split ','
      [name, count] = pair.split /\s*=\s+/, 2
      continue if name is ''
      @proctypes[name].scale(count)

exports.createFormation = (args...) ->
  new Formation args...
