http = require 'http'

{createProcess}   = require '../src/process'
{CapturingStream} = require '../src/streams'

{setupFixtures} = require './fixtures'
exports.setUp = setupFixtures

spawnSimple = (callback) ->
  myProc = createProcess 'simple', "ruby ./simple", cwd: "#{__dirname}/fixtures/example"
  myProc.spawn -> callback(myProc)

exports.testProcessNameSentAsPS = (test) ->
  test.expect 1

  procName = 'namer.7'
  capture = new CapturingStream()
  myProc = createProcess procName, "echo $PS", {pad: 10, max: 1, output: capture}

  myProc.on 'stop', ->
    output  = capture.output.toString().trim()
    matcher = "[0-9:]{8} #{procName} *| #{procName}"
    match   = output.match(matcher)
    test.ok match
    test.done()

  myProc.spawn()

exports.testStop = (test) ->
  test.expect 1
  spawnSimple (myProc) ->
    myProc.stop ->
      test.ok true
      test.done()

exports.testSpawnWeb = (test) ->
  test.expect 2

  myProc = createProcess 'web', "bundle exec thin start -p $PORT", cwd: "#{__dirname}/fixtures/app"
  myProc.timeout = 3000

  myProc.on 'error', (err) ->
    test.ifError err
    myProc.stop()

  myProc.spawn ->
    test.ok myProc.port
    myProc.child.on 'exit', ->
      test.done()

    req = http.request host: '127.0.0.1', port: myProc.port, (res) ->
      test.same 200, res.statusCode
      myProc.stop()
    req.end()


exports.testSpawnTimeout = (test) ->
  test.expect 1

  myProc = createProcess 'web', "sleep 3", cwd: "#{__dirname}/fixtures/app"
  myProc.timeout = 100
  myProc.spawn (myProc) ->
    test.ok false
    myProc.stop ->
      test.done()

  myProc.on 'error', (err) ->
    test.ok err
    myProc.stop ->
      test.done()
