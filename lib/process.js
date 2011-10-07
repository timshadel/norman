(function() {
  var Process, WebProcess, getOpenPort, net, spawn;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __slice = Array.prototype.slice;
  net = require('net');
  spawn = require('child_process').spawn;
  Process = (function() {
    function Process(name, command, cwd) {
      this.name = name;
      this.command = command;
      this.cwd = cwd;
    }
    Process.prototype.spawn = function() {
      var env, key, value, _ref;
      env = {};
      _ref = process.env;
      for (key in _ref) {
        value = _ref[key];
        env[key] = value;
      }
      if (this.port) {
        env['PORT'] = this.port;
      }
      env['PS'] = "" + this.name + ".1";
      console.error("" + this.name + ".1: " + this.command);
      this.child = spawn('/bin/sh', ['-c', this.command], {
        env: env,
        cwd: this.cwd
      });
      this.child.stdout.pipe(process.stdout, {
        end: false
      });
      return this.child.stderr.pipe(process.stderr, {
        end: false
      });
    };
    return Process;
  })();
  WebProcess = (function() {
    __extends(WebProcess, Process);
    function WebProcess() {
      WebProcess.__super__.constructor.apply(this, arguments);
    }
    WebProcess.prototype.spawn = function() {
      this.port = getOpenPort();
      return WebProcess.__super__.spawn.apply(this, arguments);
    };
    return WebProcess;
  })();
  getOpenPort = function() {
    var port, server;
    server = net.createServer();
    server.listen(0);
    port = server.address().port;
    server.close();
    return port;
  };
  exports.createProcess = function() {
    var args, name;
    name = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    if (name === 'web') {
      return (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return typeof result === "object" ? result : child;
      })(WebProcess, [name].concat(__slice.call(args)), function() {});
    } else {
      return (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return typeof result === "object" ? result : child;
      })(Process, [name].concat(__slice.call(args)), function() {});
    }
  };
}).call(this);
