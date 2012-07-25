{spawn} = require 'child_process'

task 'test', "Run test suite", ->
  process.chdir __dirname
  {reporters} = require 'nodeunit'
  reporters.default.run ['test']
