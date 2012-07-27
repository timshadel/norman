http = require 'http'

{createPool} = require '../src/pool'

{setupFixtures} = require './fixtures'
exports.setUp = setupFixtures

async = require 'async'

spawnSimple = (callback) ->
  pool = createPool 'simple', "ruby ./simple", cwd: "#{__dirname}/fixtures/example"
  pool.spawn -> callback(pool)

exports.testSpawn = (test) ->
  test.expect 0

  pool = createPool 'simple', "ruby ./simple", cwd: "#{__dirname}/fixtures/example"
  pool.spawn ->
    pool.stop ->
      test.done()

exports.testSpawnMultiple = (test) ->
  test.expect 5

  pool = createPool 'simple', "ruby ./simple", cwd: "#{__dirname}/fixtures/example", concurrency: 2
  process_names = pool.processes.map (p) -> p.name
  test.deepEqual process_names, ['simple.1', 'simple.2']

  # Processes haven't started yet
  for myProc in pool.processes
    test.ok typeof myProc.child is 'undefined'

  pool.spawn ->
    for myProc in pool.processes
      test.ok typeof myProc.child is 'object'
    pool.stop ->
      test.done()

exports.testStop = (test) ->
  test.expect 1
  spawnSimple (pool) ->
    pool.stop ->
      test.ok true
      test.done()

exports.testWebPool = (test) ->
  test.expect 5

  pool = createPool 'web', "bundle exec thin start -p $PORT", cwd: "#{__dirname}/fixtures/app", concurrency: 2

  pool.spawn ->
    testRequest = (myProc, cb) ->
      test.ok myProc.port
      req = http.request host: '127.0.0.1', port: myProc.port, (res) ->
        test.same 200, res.statusCode
        cb()
      req.end()

    timeoutId = setTimeout ->
      pool.stop ->
        test.ok(false)
        test.done()
    , 20000

    async.forEach pool.processes, testRequest, (error) ->
      test.ifError error
      clearTimeout timeoutId
      pool.stop ->
        test.done()


