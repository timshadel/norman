http = require 'http'

{createPool} = require '../src/pool'

{setupFixtures} = require './fixtures'
async = require 'async'

exports.setUp = setupFixtures

spawnTicker = (callback) ->
  pool = createPool 'ticker', "ruby ./ticker", cwd: "#{__dirname}/fixtures/example"
  pool.spawn -> callback(pool)

exports.testSpawn = (test) ->
  test.expect 0

  pool = createPool 'ticker', "ruby ./ticker", cwd: "#{__dirname}/fixtures/example"
  pool.spawn ->
    pool.kill ->
      test.done()

exports.testSpawnMultiple = (test) ->
  test.expect 5

  pool = createPool 'ticker', "ruby ./ticker", cwd: "#{__dirname}/fixtures/example", concurrency: 2
  process_names = pool.processes.map (p) -> p.name
  test.deepEqual process_names, ['ticker.1', 'ticker.2']

  # Processes haven't started yet
  for process in pool.processes
    test.ok typeof process.child is 'undefined'

  pool.spawn ->
    for process in pool.processes
      test.ok typeof process.child is 'object'
    pool.kill test.done

exports.testKill = (test) ->
  test.expect 1
  spawnTicker (pool) ->
    pool.kill ->
      test.ok true
      test.done()

exports.testTerminate = (test) ->
  test.expect 1
  spawnTicker (pool) ->
    pool.terminate ->
      test.ok true
      test.done()

exports.testQuit = (test) ->
  test.expect 1
  spawnTicker (pool) ->
    pool.quit ->
      test.ok true
      test.done()

exports.testWebPool = (test) ->
  test.expect 5

  pool = createPool 'web', "bundle exec thin start -p $PORT", cwd: "#{__dirname}/fixtures/app", concurrency: 2

  pool.spawn ->
    testRequest = (process, cb) ->
      test.ok process.port
      req = http.request host: '127.0.0.1', port: process.port, (res) ->
        test.same 200, res.statusCode
        cb()
      req.end()

    timeoutId = setTimeout (-> pool.kill(-> test.ok(false); test.done())), 20000
    async.forEach pool.processes, testRequest, (error) ->
      test.ifError error
      clearTimeout timeoutId
      pool.kill test.done
