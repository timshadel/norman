(function() {
  var ProcType, clone, getOpenPort, net, prepend, spawn;
  var __slice = Array.prototype.slice;
  net = require('net');
  spawn = require('child_process').spawn;
  prepend = require('./util').prepend;
  ProcType = (function() {
    function ProcType(name, command, cwd, appName, env) {
      this.name = name;
      this.command = command;
      this.cwd = cwd;
      this.appName = appName;
      this.env = env;
      this.processes = [];
      this.nextProcNum = 1;
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
      var child, name, port;
      port = getOpenPort();
      name = "" + this.name + "." + (this.nextProcNum++);
      this.env['PORT'] = port;
      this.env['PS'] = name;
      console.error(" norman/" + this.appName + "[" + name + "]: PORT=" + port + " `" + this.command + "`");
      child = spawn('/bin/sh', ['-c', this.command], {
        env: this.env,
        cwd: this.cwd
      });
      prepend("    app/" + this.appName + "[" + name + "]: ", child.stdout).pipe(process.stdout, {
        end: false
      });
      prepend("    app/" + this.appName + "[" + name + "]: ", child.stderr).pipe(process.stderr, {
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
  clone = function(obj) {
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
