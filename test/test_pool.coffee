http = require 'http'

{createPool} = require '../lib/pool'

{setupFixtures} = require './fixtures'
exports.setUp = setupFixtures

spawnTicker = ->
  pool = createPool 'ticker', "ruby ./ticker", cwd: "#{__dirname}/fixtures/example"
  pool.spawn()
  pool

exports.testSpawn = (test) ->
  test.expect 0

  pool = createPool 'ticker', "ruby ./ticker", cwd: "#{__dirname}/fixtures/example"
  pool.spawn()

  pool.kill ->
    test.done()

exports.testSpawnMultiple = (test) ->
  test.expect 2

  pool = createPool 'ticker', "ruby ./ticker", cwd: "#{__dirname}/fixtures/example", concurrency: 2
  pool.on 'process:spawn', (process) ->
    test.ok process.name in ['ticker.1', 'ticker.2']
  pool.spawn()

  pool.kill ->
    test.done()

exports.testKill = (test) ->
  test.expect 1
  pool = spawnTicker()
  pool.kill ->
    test.ok true
    test.done()

exports.testTerminate = (test) ->
  test.expect 1
  pool = spawnTicker()
  pool.terminate ->
    test.ok true
    test.done()

exports.testQuit = (test) ->
  test.expect 1
  pool = spawnTicker()
  pool.quit ->
    test.ok true
    test.done()

exports.testWebPool = (test) ->
  test.expect 4

  pool = createPool 'web', "bundle exec thin start -p $PORT", cwd: "#{__dirname}/fixtures/app", concurrency: 2

  timeoutId = setTimeout (-> pool.kill(-> test.ok(false); test.done())), 20000
  completedRequests = 0
  complete = ->
    completedRequests++
    if completedRequests >= 2
      clearTimeout timeoutId
      pool.kill -> test.done()

  pool.on 'process:spawn', (process) ->
    test.ok process.port

    process.on 'ready', ->
      req = http.request host: '127.0.0.1', port: process.port, (res) ->
        test.same 200, res.statusCode
        complete()
      req.end()

    process.on 'error', (err) ->
      console.log "Error starting socket for #{process.name}"
      test.ifError err

  pool.spawn()
