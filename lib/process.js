(function() {
  var Process, getOpenPort, net, spawn;
  var __slice = Array.prototype.slice;
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
      this.port = getOpenPort();
      env = {};
      _ref = process.env;
      for (key in _ref) {
        value = _ref[key];
        env[key] = value;
      }
      env['PORT'] = this.port;
      env['PS'] = "" + this.name + ".1";
      console.error("" + this.name + ".1 (" + this.port + "): " + this.command);
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
  getOpenPort = function() {
    var port, server;
    server = net.createServer();
    server.listen(0);
    port = server.address().port;
    server.close();
    return port;
  };
  exports.createProcess = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return typeof result === "object" ? result : child;
    })(Process, args, function() {});
  };
}).call(this);
