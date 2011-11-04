{Stream}       = require 'stream'

# The `LineBuffer` class is a `Stream` that emits a `data` event for
# each line in the stream.
exports.LineBuffer = class LineBuffer extends Stream
  # Create a `LineBuffer` around the given stream.
  constructor: (@stream) ->
    @readable = true
    @_buffer = ""

    # Install handlers for the underlying stream's `data` and `end`
    # events.
    self = this
    @stream.on 'data', (args...) -> self.write args...
    @stream.on 'end',  (args...) -> self.end args...

  # Write a chunk of data read from the stream to the internal buffer.
  write: (chunk) ->
    @_buffer += chunk

    # If there's a newline in the buffer, slice the line from the
    # buffer and emit it. Repeat until there are no more newlines.
    while (index = @_buffer.indexOf("\n")) != -1
      line     = @_buffer[0...index]
      @_buffer = @_buffer[index+1...@_buffer.length]
      @emit 'data', line

  # Process any final lines from the underlying stream's `end`
  # event. If there is trailing data in the buffer, emit it.
  end: (args...) ->
    if args.length > 0
      @write args...
    @emit 'data', @_buffer if @_buffer.length
    @emit 'end'


exports.PrependLineBuffer = class PrependLineBuffer extends LineBuffer
  constructor: (@preamble, stream) ->
    @lineStream = new LineBuffer(stream)
    
    self = this
    @lineStream.on 'data', (line) -> self.emit 'data', "#{self.preamble}#{line}\n"
    @lineStream.on 'end', -> self.emit 'end'

exports.prepend = (args...) ->
  new PrependLineBuffer(args...)
