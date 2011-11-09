http = require 'http'

{createProcess} = require '../lib/process'

{setupFixtures} = require './fixtures'
exports.setUp = setupFixtures

spawnTicker = ->
  process = createProcess 'ticker', "ruby ./ticker", cwd: "#{__dirname}/fixtures/example"
  process.spawn()
  process

exports.testSpawn = (test) ->
  test.expect 0

  process = createProcess 'ticker', "ruby ./ticker", cwd: "#{__dirname}/fixtures/example"
  process.spawn()

  process.kill ->
    test.done()

exports.testKill = (test) ->
  test.expect 1
  process = spawnTicker()
  process.kill ->
    test.ok true
    test.done()

exports.testTerminate = (test) ->
  test.expect 1
  process = spawnTicker()
  process.terminate ->
    test.ok true
    test.done()

exports.testQuit = (test) ->
  test.expect 1
  process = spawnTicker()
  process.quit ->
    test.ok true
    test.done()

exports.testSpawnWeb = (test) ->
  test.expect 2

  process = createProcess 'web', "bundle exec thin start -p $PORT", cwd: "#{__dirname}/fixtures/app"
  process.timeout = 3000
  process.spawn()
  test.ok process.port

  process.on 'ready', ->
    req = http.request host: '127.0.0.1', port: process.port, (res) ->
      test.same 200, res.statusCode
      process.kill()
    req.end()

  process.on 'error', (err) ->
    test.ifError err
    process.kill()

  process.child.on 'exit', ->
    test.done()

exports.testSpawnTimeout = (test) ->
  test.expect 1

  process = createProcess 'web', "sleep 3", cwd: "#{__dirname}/fixtures/app"
  process.timeout = 1000
  process.spawn()

  process.on 'error', (err) ->
    test.ok err
    process.kill()

  process.child.on 'exit', ->
    test.done()
