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
    pool.kill ->
      test.done()

# exports.testSpawnMultiple = (test) ->
#   test.expect 5

#   pool = createPool 'simple', "ruby ./simple", cwd: "#{__dirname}/fixtures/example", concurrency: 2
#   process_names = pool.processes.map (p) -> p.name
#   test.deepEqual process_names, ['simple.1', 'simple.2']

#   # Processes haven't started yet
#   for myProc in pool.processes
#     test.ok typeof myProc.child is 'undefined'

#   pool.spawn ->
#     for myProc in pool.processes
#       test.ok typeof myProc.child is 'object'
#     pool.kill ->
#       test.done()

exports.testKill = (test) ->
  test.expect 1
  spawnSimple (pool) ->
    pool.kill ->
      test.ok true
      test.done()

exports.testTerminate = (test) ->
  test.expect 1
  spawnSimple (pool) ->
    pool.terminate ->
      test.ok true
      test.done()

# exports.testQuit = (test) ->
#   test.expect 1
#   spawnSimple (pool) ->
#     pool.quit ->
#       test.ok true
#       test.done()

# exports.testWebPool = (test) ->
#   test.expect 5

#   pool = createPool 'web', "bundle exec thin start -p $PORT", cwd: "#{__dirname}/fixtures/app", concurrency: 2

#   pool.spawn ->
#     testRequest = (myProc, cb) ->
#       test.ok myProc.port
#       req = http.request host: '127.0.0.1', port: myProc.port, (res) ->
#         test.same 200, res.statusCode
#         cb()
#       req.end()

#     timeoutId = setTimeout ->
#       pool.kill ->
#         test.ok(false)
#         test.done()
#     , 20000

#     async.forEach pool.processes, testRequest, (error) ->
#       test.ifError error
#       clearTimeout timeoutId
#       pool.kill test.done


