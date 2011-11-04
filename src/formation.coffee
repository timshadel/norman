{readFile}       = require 'fs'
{basename, dirname, join}  = require 'path'

{createProcType} = require './proctype'

class Formation
  constructor: (@procfile, callback) ->
    @cwd = dirname @procfile
    @appName = basename @cwd
    @proctypes = {}
    @env = {}
    for key, value of process.env
      @env[key] = value
      
    @loadEnv =>
      @loadProcfile =>
        callback(this)
  
  scale: (concurrency = 'web=1') ->
    for pair in concurrency.split ','
      [name, count] = pair.split '=', 2
      continue if name is ''
      @proctypes[name].scale(count)


  loadEnv: (next) ->
    readFile join(@cwd, '.env'), 'utf-8', (err, data) =>
      next() if err
      for line in data.split "\n"
        [name, value] = line.split '=', 2
        continue if name is ''
        @env[name] = value
      next()

  loadProcfile: (next) ->
    readFile @procfile, 'utf-8', (err, data) =>
      for line in data.split "\n"
        [name, command] = line.split /\s*:\s+/, 2
        continue if name is ''
        @proctypes[name] = createProcType name, command, @cwd, @appName, @env
      next()

  
exports.createFormation = (args...) ->
  new Formation args...
