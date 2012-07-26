{readFile} = require 'fs'
{dirname}  = require 'path'

{createPool}       = require './pool'
{ForwardingStream} = require './streams'

async = require 'async'

class Formation
  @colors = [ "cyan", "yellow", "green", "magenta", "red", "blue", "cyan+bold", "yellow+bold",
                     "green+bold", "magenta+bold", "red+bold", "blue+bold" ]

  constructor: (details, options) ->
    @pools = {}
    @output = new ForwardingStream

    process_names = Object.keys details
    max = Math.max.apply @, process_names.map (e) -> e.length

    # 2 for '.1' or '.9', assuming nobody uses more than 9 in dev
    options.pad = max + 2

    for name, command of details
      options.color = Formation.colors[Object.keys(@pools).length % Formation.colors.length]
      @pools[name] = createPool name, command, options

  spawn: (callback) ->
    spawn = (pool, cb) => pool.output.pipe @output, end: false; pool.spawn cb
    async.forEach (pool for name, pool of @pools), spawn, callback

exports.createFormation = (args...) ->
  new Formation args...
