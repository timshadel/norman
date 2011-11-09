{exec} = require 'child_process'

complete = false

exports.setUp = (callback) ->
  if complete
    callback()
  else
    bundleInstall "#{__dirname}/fixtures/app/Gemfile", (err) ->
      complete = !err
      callback err

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
