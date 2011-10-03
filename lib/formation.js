(function() {
  var Formation, clone, createProcType, path, readFile;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __slice = Array.prototype.slice;
  readFile = require('fs').readFile;
  path = require('path');
  createProcType = require('./proctype').createProcType;
  clone = require('./util').clone;
  Formation = (function() {
    function Formation(procfile, callback) {
      var envPath, readEnvFile, readProcfile;
      this.procfile = procfile;
      this.cwd = path.dirname(this.procfile);
      envPath = path.join(this.cwd, '.env');
      this.proctypes = {};
      this.env = clone(process.env);
      readEnvFile = __bind(function(next) {
        return readFile(envPath, 'utf-8', __bind(function(err, data) {
          var line, name, value, _i, _len, _ref, _ref2;
          _ref = data.split("\n");
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            line = _ref[_i];
            _ref2 = line.split('=', 2), name = _ref2[0], value = _ref2[1];
            if (name === '') {
              continue;
            }
            this.env[name] = value;
          }
          return next();
        }, this));
      }, this);
      readProcfile = __bind(function(next) {
        return readFile(this.procfile, 'utf-8', __bind(function(err, data) {
          var command, line, name, _i, _len, _ref, _ref2;
          _ref = data.split("\n");
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            line = _ref[_i];
            _ref2 = line.split(/\s*:\s+/, 2), name = _ref2[0], command = _ref2[1];
            if (name === '') {
              continue;
            }
            this.proctypes[name] = createProcType(name, command, this.cwd, this.env);
          }
          return next();
        }, this));
      }, this);
      path.exists(envPath, __bind(function(exists) {
        if (exists) {
          return readEnvFile(__bind(function() {
            return readProcfile(__bind(function() {
              return callback(this);
            }, this));
          }, this));
        } else {
          return readProcfile(__bind(function() {
            return callback(this);
          }, this));
        }
      }, this));
    }
    Formation.prototype.scale = function(concurrency) {
      var count, name, pair, _i, _len, _ref, _ref2, _results;
      if (concurrency == null) {
        concurrency = 'web=1';
      }
      _ref = concurrency.split(',');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        pair = _ref[_i];
        _ref2 = pair.split('=', 2), name = _ref2[0], count = _ref2[1];
        if (name === '') {
          continue;
        }
        _results.push(this.proctypes[name].scale(count));
      }
      return _results;
    };
    return Formation;
  })();
  exports.createFormation = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return typeof result === "object" ? result : child;
    })(Formation, args, function() {});
  };
}).call(this);
