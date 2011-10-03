(function() {
  exports.clone = function(obj) {
    var constructor, key, newInstance, _ref;
    if (!(obj != null) || typeof obj !== 'object') {
      return obj;
    }
    constructor = (_ref = obj.constructor) != null ? _ref : Object.constructor;
    newInstance = new constructor();
    for (key in obj) {
      newInstance[key] = exports.clone(obj[key]);
    }
    return newInstance;
  };
}).call(this);
