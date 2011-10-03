(function() {
  var ProcType, clone, getOpenPort, net, spawn;
  var __slice = Array.prototype.slice;
  net = require('net');
  spawn = require('child_process').spawn;
  clone = require('./util').clone;
  ProcType = (function() {
    function ProcType(name, command, cwd, env) {
      this.name = name;
      this.command = command;
      this.cwd = cwd;
      this.processes = [];
      this.nextProcNum = 1;
      this.env = clone(env);
    }
    ProcType.prototype.scale = function(count) {
      var _i, _j, _ref, _ref2, _results, _results2;
      if (count === this.processes.length) {
        return;
      }
      if (this.processes.length > count) {
        _results = [];
        for (_i = count, _ref = this.processes.length; count <= _ref ? _i < _ref : _i > _ref; count <= _ref ? _i++ : _i--) {
          _results.push(this.kill());
        }
        return _results;
      } else {
        _results2 = [];
        for (_j = _ref2 = this.processes.length; _ref2 <= count ? _j < count : _j > count; _ref2 <= count ? _j++ : _j--) {
          _results2.push(this.spawn());
        }
        return _results2;
      }
    };
    ProcType.prototype.spawn = function() {
      var child, env, name, port;
      port = getOpenPort();
      name = "" + this.name + "." + (this.nextProcNum++);
      env = clone(this.env);
      env['PORT'] = port;
      env['PS'] = name;
      console.error("" + name + " (" + port + "): " + this.command);
      child = spawn('/bin/sh', ['-c', this.command], {
        env: env,
        cwd: this.cwd
      });
      child.stdout.pipe(process.stdout, {
        end: false
      });
      child.stderr.pipe(process.stderr, {
        end: false
      });
      return this.processes.push({
        child: child,
        port: port,
        name: name
      });
    };
    return ProcType;
  })();
  getOpenPort = function() {
    var port, server;
    server = net.createServer();
    server.listen(0);
    port = server.address().port;
    server.close();
    return port;
  };
  exports.createProcType = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return typeof result === "object" ? result : child;
    })(ProcType, args, function() {});
  };
}).call(this);
