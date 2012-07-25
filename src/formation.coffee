{readFile} = require 'fs'
{dirname}  = require 'path'

{parseProcfile}    = require './procfile'
{createPool}       = require './pool'
{ForwardingStream} = require './streams'

class Formation
  @colors = [ "cyan", "yellow", "green", "magenta", "red", "blue", "cyan+bold", "yellow+bold",
                     "green+bold", "magenta+bold", "red+bold", "blue+bold" ]

  constructor: (details, options) ->
    @pools = {}
    @out = new ForwardingStream

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
      pool.on 'pool:ready', =>
        pool.out.pipe @out, end: false

      pool.spawn()

exports.createFormation = (args...) ->
  new Formation args...
