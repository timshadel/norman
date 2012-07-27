# Wrapper for simple async iterators
call = (name) ->
  (obj, callback) ->
    if typeof obj?[name] is 'function'
      obj[name].apply obj, [callback]
    else
      callback(new Error("'#{obj}' doesn't have a function named '#{name}'"))

module.exports = call