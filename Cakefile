{spawn} = require 'child_process'

task 'build', "Build CoffeeScript source files", ->
  coffee = spawn 'coffee', ['-cw', '-o', 'lib', 'src']
  coffee.stdout.on 'data', (data) -> process.stderr.write data.toString()
