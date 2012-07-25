{Stream} = require 'stream'

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

# **PrependingBuffer** adds the output of a function to the beginning of
# each data segment emitted by the underlying stream.
#
class CapturingStream extends ForwardingStream
  constructor: (preamble) ->
    super
    @_capture = ""

  write: (chunk) ->
    @_capture += chunk
    super chunk

  ended: ->
    @emit 'captured', @_capture
    super

exports.LineBuffer       = LineBuffer
exports.PrependingBuffer = PrependingBuffer
exports.ForwardingStream = ForwardingStream
exports.CapturingStream  = CapturingStream
