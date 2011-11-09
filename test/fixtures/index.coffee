{exec} = require 'child_process'

complete = false

exports.setupFixtures = (callback) ->
  if complete
    callback()
  else
    bundleInstall "#{__dirname}/app/Gemfile", (err) ->
      throw err if err
      complete = true
      callback()

bundleInstall = (gemfile, callback) ->
  env = {}
  for key, value of process.env
    env[key] = value

  env['BUNDLE_GEMFILE'] = gemfile

  exec "bundle check", {env}, (err) ->
    if err
      exec "bundle install", {env}, callback
    else
      callback err
