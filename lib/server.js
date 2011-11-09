(function() {
  var Server, createPool, dirname, parseProcfile, readFile;
  var __slice = Array.prototype.slice;

  readFile = require('fs').readFile;

  dirname = require('path').dirname;

  parseProcfile = require('./procfile').parseProcfile;

  createPool = require('./pool').createPool;

  Server = (function() {

    function Server(procfile, callback) {
      var _this = this;
      this.procfile = procfile;
      this.cwd = dirname(this.procfile);
      this.pools = {};
      parseProcfile(this.procfile, function(err, procfile) {
        var command, name;
        for (name in procfile) {
          command = procfile[name];
          _this.pools[name] = createPool(name, command, {
            cwd: _this.cwd
          });
        }
        return callback(_this);
      });
    }

    Server.prototype.spawn = function() {
      var name, pool, _ref, _results;
      _ref = this.pools;
      _results = [];
      for (name in _ref) {
        pool = _ref[name];
        pool.on('process:spawn', function(proc) {
          console.error("" + proc.name + ": " + proc.command);
          proc.child.stdout.pipe(process.stdout, {
            end: false
          });
          proc.child.stderr.pipe(process.stderr, {
            end: false
          });
          return proc.on('ready', function() {
            return console.error("" + proc.name + ": ready on " + proc.port);
          });
        });
        _results.push(pool.spawn());
      }
      return _results;
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
