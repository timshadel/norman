{createProcess} = require '../lib/process'

spawnTicker = ->
  process = createProcess 'ticker', "ruby ./ticker", "#{__dirname}/fixtures/example"
  process.spawn()
  process

exports.testSpawn = (test) ->
  test.expect 0

  process = createProcess 'ticker', "ruby ./ticker", "#{__dirname}/fixtures/example"
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
