{readFile} = require 'fs'
{dirname}  = require 'path'

{createPool}       = require './pool'

async = require 'async'
call  = require './call'

class Colors
  @colors = [ "cyan", "yellow", "green", "magenta", "red", "blue", "cyan+bold", "yellow+bold",
                     "green+bold", "magenta+bold", "red+bold", "blue+bold" ]

  constructor: -> @index = 0

  next_color: -> Colors.colors[@index++ % Colors.colors.length]


class Formation

  constructor: (details, options) ->
    @pools = {}

    colors        = new Colors
    process_names = Object.keys details
    longest_name  = Math.max.apply @, process_names.map (e) -> e.length
    suffix_width  = 2 # proc.1 up to proc.9

    options.pad   = longest_name + suffix_width
    options.color = -> colors.next_color()

    for name, command of details
      @pools[name] = createPool name, command, options

  spawn: (callback) ->
    async.forEach (pool for name, pool of @pools), call("spawn"), callback

exports.createFormation = (args...) ->
  new Formation args...
