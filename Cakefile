{spawn} = require 'child_process'

task 'build', "Build CoffeeScript source files", ->
  coffee = spawn 'coffee', ['-cw', '-o', 'lib', 'src']
  coffee.stdout.on 'data', (data) -> process.stderr.write data.toString()

task 'test', "Run test suite", ->
  process.chdir __dirname
  {reporters} = require 'nodeunit'
  reporters.default.run ['test']

task 'setup', "Setup environment", ->
  process.stderr.write "Running `bundle install` for test Ruby app..."
  process.chdir "#{__dirname}/test/fixtures/app"
  bundle = spawn 'bundle', ['install']
  bundle.stdout.on 'data', (data) -> process.stderr.write data.toString()
