http = require 'http'

{createProcess}   = require '../src/process'
{CapturingStream} = require '../src/streams'

{setupFixtures} = require './fixtures'
exports.setUp = setupFixtures

spawnSimple = (callback) ->
  myProc = createProcess 'simple', "ruby ./simple", cwd: "#{__dirname}/fixtures/example"
  myProc.spawn -> callback(myProc)

exports.testProcessName = (test) ->
  test.expect 1

  procName = 'namer.7'
  myProc = createProcess procName, "echo $PS", {pad: 10}
  capture = new CapturingStream()
  myProc.output.pipe capture

  capture.on 'captured', (output) ->
    output  = output.toString().trim()
    matcher = "[0-9:]{8} #{procName} *| #{procName}"
    match   = output.match(matcher)
    test.ok match
    test.done()

  myProc.spawn()

exports.testKill = (test) ->
  test.expect 1
  spawnSimple (myProc) ->
    myProc.kill ->
      test.ok true
      test.done()

exports.testTerminate = (test) ->
  test.expect 1
  spawnSimple (myProc) ->
    myProc.terminate ->
      test.ok true
      test.done()

exports.testQuit = (test) ->
  test.expect 1
  spawnSimple (myProc) ->
    myProc.quit ->
      test.ok true
      test.done()

# exports.testSpawnWeb = (test) ->
#   test.expect 2

#   myProc = createProcess 'web', "bundle exec thin start -p $PORT", cwd: "#{__dirname}/fixtures/app"
#   myProc.timeout = 3000

#   myProc.on 'ready', ->
#     test.ok myProc.port
#     myProc.child.on 'exit', ->
#       test.done()

#     req = http.request host: '127.0.0.1', port: myProc.port, (res) ->
#       test.same 200, res.statusCode
#       myProc.kill()
#     req.end()

#   myProc.on 'error', (err) ->
#     test.ifError err
#     myProc.kill()

#   myProc.spawn()


exports.testSpawnTimeout = (test) ->
  test.expect 1

  myProc = createProcess 'web', "sleep 3", cwd: "#{__dirname}/fixtures/app"
  myProc.timeout = 100
  myProc.spawn (myProc) ->
    test.ok false
    myProc.kill ->
      test.done()

  myProc.on 'error', (err) ->
    test.ok err
    myProc.kill ->
      test.done()
