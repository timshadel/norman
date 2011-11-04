(function() {
  var Formation, basename, createProcType, dirname, join, readFile, _ref;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __slice = Array.prototype.slice;
  readFile = require('fs').readFile;
  _ref = require('path'), basename = _ref.basename, dirname = _ref.dirname, join = _ref.join;
  createProcType = require('./proctype').createProcType;
  Formation = (function() {
    function Formation(procfile, callback) {
      var key, value, _ref2;
      this.procfile = procfile;
      this.cwd = dirname(this.procfile);
      this.appName = basename(this.cwd);
      this.proctypes = {};
      this.env = {};
      _ref2 = process.env;
      for (key in _ref2) {
        value = _ref2[key];
        this.env[key] = value;
      }
      this.loadEnv(__bind(function() {
        return this.loadProcfile(__bind(function() {
          return callback(this);
        }, this));
      }, this));
    }
    Formation.prototype.scale = function(concurrency) {
      var count, name, pair, _i, _len, _ref2, _ref3, _results;
      if (concurrency == null) {
        concurrency = 'web=1';
      }
      _ref2 = concurrency.split(',');
      _results = [];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        pair = _ref2[_i];
        _ref3 = pair.split('=', 2), name = _ref3[0], count = _ref3[1];
        if (name === '') {
          continue;
        }
        _results.push(this.proctypes[name].scale(count));
      }
      return _results;
    };
    Formation.prototype.loadEnv = function(next) {
      return readFile(join(this.cwd, '.env'), 'utf-8', __bind(function(err, data) {
        var line, name, value, _i, _len, _ref2, _ref3;
        if (err) {
          next();
        }
        _ref2 = data.split("\n");
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          line = _ref2[_i];
          _ref3 = line.split('=', 2), name = _ref3[0], value = _ref3[1];
          if (name === '') {
            continue;
          }
          this.env[name] = value;
        }
        return next();
      }, this));
    };
    Formation.prototype.loadProcfile = function(next) {
      return readFile(this.procfile, 'utf-8', __bind(function(err, data) {
        var command, line, name, _i, _len, _ref2, _ref3;
        _ref2 = data.split("\n");
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          line = _ref2[_i];
          _ref3 = line.split(/\s*:\s+/, 2), name = _ref3[0], command = _ref3[1];
          if (name === '') {
            continue;
          }
          this.proctypes[name] = createProcType(name, command, this.cwd, this.appName, this.env);
        }
        return next();
      }, this));
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
