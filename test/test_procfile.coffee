{parseProcfile} = require '../lib/procfile'

{setupFixtures} = require './fixtures'
exports.setUp = setupFixtures

exports.testParseAppProcfile = (test) ->
  test.expect 4
  parseProcfile "#{__dirname}/fixtures/app/Procfile", (err, procfile) ->
    test.ifError err
    test.same "bundle exec thin start -p $PORT", procfile.web
    test.same "bundle exec rake resque:work QUEUE=*", procfile.worker
    test.same "bundle exec rake resque:scheduler", procfile.clock
    test.done()

exports.testParseExampleProcfile = (test) ->
  test.expect 3
  parseProcfile "#{__dirname}/fixtures/example/Procfile", (err, procfile) ->
    test.ifError err
    test.same "ruby ./ticker $PORT", procfile.ticker
    test.same "ruby ./error", procfile.error
    test.done()

exports.testParseMissingProcfile = (test) ->
  test.expect 1
  parseProcfile "#{__dirname}/fixtures/null/Procfile", (err, procfile) ->
    test.ok err
    test.done()
