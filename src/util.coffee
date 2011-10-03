# Deep copy
# http://coffeescriptcookbook.com/chapters/classes_and_objects/cloning
exports.clone = (obj) ->
  if not obj? or typeof obj isnt 'object'
    return obj

  # process.env has no constructor...
  constructor = obj.constructor ? Object.constructor
  newInstance = new constructor()

  for key of obj
    newInstance[key] = exports.clone obj[key]

  return newInstance
