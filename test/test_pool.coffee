{createPool} = require '../lib/pool'

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
  test.expect 0

  pool = createPool 'ticker', "ruby ./ticker", cwd: "#{__dirname}/fixtures/example", concurrency: 2
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