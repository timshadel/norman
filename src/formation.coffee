{readFile} = require 'fs'
{dirname}  = require 'path'

{parseProcfile} = require './procfile'
{createPool}    = require './pool'

class Formation
  @colors = [ "cyan", "yellow", "green", "magenta", "red", "blue", "cyan+bold", "yellow+bold",
                     "green+bold", "magenta+bold", "red+bold", "blue+bold" ]

  constructor: (details, options) ->
    @pools = {}

    max = 6
    count = 0
    for name, command of details
      max = name.length if name.length > max
      count++

    # 2 for '.1' or '.9', assuming nobody uses more than 9 in dev
    options.pad = max + 2

    i = 0
    for name, command of details
      options.color = Formation.colors[i % Formation.colors.length]
      @pools[name] = createPool name, command, options
      i++

  spawn: ->
    for name, pool of @pools
      # TODO: push output handling down to the pool, and aggregate them here
      #       the Server should push to STDOUT, not the formation
      pool.on 'process:spawn', (proc) ->
        proc.out.pipe process.stdout, end: false

      pool.spawn()

exports.createFormation = (args...) ->
  new Formation args...
