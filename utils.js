exports.getTask = function () {
    var args = arguments;

    return function (name) {
        var task = require('./tasks/' + name);

        return task.apply(task, args);
    }
};

exports.exec = function (cmd) {
  var exec = require('child_process').exec;

  exec(cmd, function (error, stdout, stderr) {
      console.log(stdout);
      console.error(stderr);
  });
};

exports.log = function (item, cb) {
    console.log(item.path || item);
    if (cb) cb(null, item);
};
