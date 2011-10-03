# Deep copy
# http://coffeescriptcookbook.com/chapters/classes_and_objects/cloning
exports.clone = (obj) ->
  if not obj? or typeof obj isnt 'object'
    return obj

  newInstance = new obj.constructor()

  for key of obj
    newInstance[key] = clone obj[key]

  return newInstance
