{readFile} = require 'fs'

class Procfile

exports.parseProcfile = (filename, callback) ->
  readFile filename, 'utf-8', (err, data) =>
    return callback err if err
    procfile = new Procfile
    for line in data.split "\n"
      if m = line.match /^([A-Za-z0-9_]+):\s*(.+)$/
        procfile[m[1]] = m[2]
    callback err, procfile
