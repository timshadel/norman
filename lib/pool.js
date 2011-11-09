(function() {
  var EventEmitter, Pool, WebPool, async, createProcess;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; }, __slice = Array.prototype.slice;

  createProcess = require('./process').createProcess;

  EventEmitter = require('events').EventEmitter;

  async = require('async');

  Pool = (function() {

    __extends(Pool, EventEmitter);

    function Pool(name, command, options) {
      var instance, _ref, _ref2;
      this.name = name;
      this.command = command;
      if (options == null) options = {};
      this.concurrency = (_ref = options.concurrency) != null ? _ref : 1;
      this.processes = [];
      for (instance = 1, _ref2 = this.concurrency; 1 <= _ref2 ? instance <= _ref2 : instance >= _ref2; 1 <= _ref2 ? instance++ : instance--) {
        this.processes.push(createProcess("" + this.name + "." + instance, this.command, options));
      }
    }

    Pool.prototype.spawn = function() {
      var process, _i, _len, _ref, _results;
      _ref = this.processes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        process = _ref[_i];
        process.spawn();
        _results.push(this.emit('process:spawn', process));
      }
      return _results;
    };

    Pool.prototype.kill = function(callback) {
      var kill;
      kill = function(process, cb) {
        return process.kill(cb);
      };
      return async.forEach(this.processes, kill, callback);
    };

    Pool.prototype.terminate = function(callback) {
      var terminate;
      terminate = function(process, cb) {
        return process.terminate(cb);
      };
      return async.forEach(this.processes, terminate, callback);
    };

    Pool.prototype.quit = function(callback) {
      var quit;
      quit = function(process, cb) {
        return process.quit(cb);
      };
      return async.forEach(this.processes, quit, callback);
    };

    return Pool;

  })();

  WebPool = (function() {

    __extends(WebPool, Pool);

    function WebPool() {
      WebPool.__super__.constructor.apply(this, arguments);
    }

    return WebPool;

  })();

  exports.createPool = function() {
    var args, name;
    name = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    if (name === 'web') {
      return (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return typeof result === "object" ? result : child;
      })(WebPool, [name].concat(__slice.call(args)), function() {});
    } else {
      return (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return typeof result === "object" ? result : child;
      })(Pool, [name].concat(__slice.call(args)), function() {});
    }
  };

}).call(this);
