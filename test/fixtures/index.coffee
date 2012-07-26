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
      console.error "Installing bundle for #{gemfile}"
      exec "bundle install", {env}, (err) ->
        console.error "...done"
        callback(err)
    else
      callback err

console.log "Fixtures", exports