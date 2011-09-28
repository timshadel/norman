(function() {
  var Server, createProcess, dirname, readFile;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __slice = Array.prototype.slice;
  readFile = require('fs').readFile;
  dirname = require('path').dirname;
  createProcess = require('./process').createProcess;
  Server = (function() {
    function Server(procfile, callback) {
      this.procfile = procfile;
      this.cwd = dirname(this.procfile);
      this.processes = {};
      readFile(this.procfile, 'utf-8', __bind(function(err, data) {
        var command, line, name, _i, _len, _ref, _ref2;
        _ref = data.split("\n");
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          line = _ref[_i];
          _ref2 = line.split(/\s*:\s+/, 2), name = _ref2[0], command = _ref2[1];
          if (name === '') {
            continue;
          }
          this.processes[name] = createProcess(name, command, this.cwd);
        }
        return callback(this);
      }, this));
    }
    Server.prototype.spawn = function(name) {
      var process, _ref, _results;
      if (name) {
        return this.processes[name].spawn();
      } else {
        _ref = this.processes;
        _results = [];
        for (name in _ref) {
          process = _ref[name];
          _results.push(process.spawn());
        }
        return _results;
      }
    };
    return Server;
  })();
  exports.createServer = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return typeof result === "object" ? result : child;
    })(Server, args, function() {});
  };
}).call(this);
