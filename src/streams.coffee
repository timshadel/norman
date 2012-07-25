{Stream, WritableStream} = require 'stream'

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
class LineBuffer extends Stream
  constructor: ->
    @readable = true
    @_buffer = ""

    @on 'pipe', (src) =>
      src.on 'data', (args...) => @write args...
      src.on 'end',  (args...) => @end args...

  write: (chunk) ->
    @_buffer += chunk

    while (index = @_buffer.indexOf("\n")) != -1
      line     = @_buffer[0...index] + '\n'
      @_buffer = @_buffer[index+1...@_buffer.length]

      # Emit `data` line as a single line
      @emit 'data', line

  end: (args...) ->
    if args.length > 0
      @write args...

    if @_buffer.length > 0
      @emit 'data', @_buffer

    @emit 'end'


# **PrependingBuffer** adds the output of a function to the beginning of
# each data segment emitted by the underlying stream.
#
class PrependingBuffer extends Stream
  constructor: (preamble) ->
    @preamble = if typeof preamble is 'function' then preamble else -> preamble.toString()

    @on 'pipe', (src) =>
      src.on 'data', (args...) => @write args...
      src.on 'end',  (args...) => @end args...

  write: (chunk) ->
    @emit 'data', (@preamble() + chunk)

  end: (args...) ->
    if args.length > 0
      @write args...

    @emit 'end'


# **ForwardingStream** simply pushes events through it. It can act like
# an aggregator since any number of streams may call 'pipe' on it.
#
class ForwardingStream extends Stream
  constructor: ->
    @on 'pipe', (src) =>
      src.on 'data', (args...) => @write args...
      src.on 'end',  (args...) => @end args...

  write: (chunk) ->
    @emit 'data', chunk

  end: (args...) ->
    if args.length > 0
      @write args...

    @emit 'end'


exports.LineBuffer       = LineBuffer
exports.PrependingBuffer = PrependingBuffer
exports.ForwardingStream = ForwardingStream

