http  = require 'http'
async = require 'async'

{createPool}      = require '../src/pool'
{CapturingStream} = require '../src/streams'
{setupFixtures}   = require './fixtures'
exports.setUp     = setupFixtures

spawnSimple = (callback) ->
  pool = createPool 'simple', "ruby ./simple", cwd: "#{__dirname}/fixtures/example"
  pool.spawn -> callback(pool)

exports.testSpawn = (test) ->
  test.expect 0

  pool = createPool 'simple', "ruby ./simple", cwd: "#{__dirname}/fixtures/example"
  pool.spawn ->
    pool.stop ->
      test.done()

exports.testMultipleProcessOutputsKeptSeparate = (test) ->
  test.expect 5

  capture = new CapturingStream()
  pool = createPool 'namer', "echo $PS",
    cwd: "#{__dirname}/fixtures/example"
    max: 1
    concurrency: 2
    output: capture

  pool.spawn ->
    pool.stop ->
      lines = capture.output.trim().split('\n')
      names = []
      for line in lines
        matcher = "^[0-9:]{8} ([a-z.1-2]+) *\\| ([a-z.1-2]+)"
        match = line.match(matcher)
        test.ok match
        test.same match[1], match[2]
        names.push match[1]

      test.deepEqual names.sort(), ['namer.1', 'namer.2']

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

  pool.on 'error', (error) ->
    console.log error
    test.ok false
    test.done()

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


