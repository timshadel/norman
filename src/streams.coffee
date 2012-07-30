{Stream} = require 'stream'
strftime = require 'strftime'
sprintf  = require('sprintf').sprintf
color    = require("ansi-color").set

# **ForwardingStream** simply pushes events through it. It can act like
# an aggregator since any number of streams may call 'pipe' on it.
#
class ForwardingStream extends Stream
  constructor: ->
    @writable = true
    @readable = true

  write: (chunk) ->
    @emit 'data', chunk

  ended: ->
    @emit 'end'

  end: (args...) ->
    if args.length > 0
      @write args...

    process.nextTick =>
      @ended()

  destroySoon: ->
    @on 'end', => @destroy()
    @end()

  destroy: ->
    @emit 'close'


# **LineBuffer** wraps any readable stream and buffers data until
# it encounters a `\n` line break. It will emit `data` events as lines
# instead of arbitrarily chunked text.
#
#     stdoutLines = new LineBuffer()
#     stdoutStream.pipe stdoutLines
#
#     stdoutLines.on 'data', (line) ->
#       if line.match "TO: "
#         console.log line
#
class LineBuffer extends ForwardingStream
  constructor: ->
    super
    @_buffer = ""

  write: (chunk) ->
    @_buffer += chunk

    while (index = @_buffer.indexOf("\n")) != -1
      line     = @_buffer[0...index] + '\n'
      @_buffer = @_buffer[index+1...@_buffer.length]

      # Emit `data` line as a single line
      @emit 'data', line

  ended: ->
    if @_buffer.length > 0
      @emit 'data', @_buffer
    super


# **PrependingBuffer** adds the output of a function to the beginning of
# each data segment emitted by the underlying stream.
#
class PrependingBuffer extends ForwardingStream
  constructor: (preamble) ->
    super
    @preamble = if typeof preamble is 'function' then preamble else -> preamble.toString()

  write: (chunk) ->
    @emit 'data', (@preamble() + chunk)


# **NamedStream** adds the output of a function to the beginning of
# each data segment emitted by the underlying stream.
#
class NamedStream extends PrependingBuffer
  constructor: (@name, @nameFieldWidth, @color) ->
    super @nameHeader

  nameHeader: ->
    format = "%-#{@nameFieldWidth}s"
    nameHeader = "#{strftime("%H:%M:%S")} #{sprintf(format, @name)} | "
    nameHeader = color(nameHeader, @color) if @color?
    nameHeader


# **ProcessOutputStream** merges a process's stdout and stdin into
# a single, `\n` delimited stream of text with each line prepended
# with a date and process name.
#
class ProcessOutputStream extends NamedStream
  constructor: (@name, @nameFieldWidth, @color, @destination) ->
    super @name, @nameFieldWidth, @color

    @stdout = new LineBuffer()
    @stderr = new LineBuffer()

    @stdout.pipe @
    @stderr.pipe @
    @pipe @destination, end: false if destination?


# **CapturingStream** acts like `tee` by pushing the data both to the
# destination stream, as well as capturing the output in a buffer. Used
# for test cases.
#
class CapturingStream extends ForwardingStream
  constructor: ->
    super
    @output = ""

  write: (chunk) ->
    @output += chunk
    super chunk

  ended: ->
    super
    @emit 'captured', @output

exports.LineBuffer       = LineBuffer
exports.PrependingBuffer = PrependingBuffer
exports.ForwardingStream = ForwardingStream
exports.CapturingStream  = CapturingStream
exports.NamedStream      = NamedStream
exports.ProcessOutputStream = ProcessOutputStream