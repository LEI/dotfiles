'use strict';

var fs = require('fs'),
    path = require('path'),
    through = require('through2'),
    util = require('util'),
    gutil = require('gulp-util'),
    gmatch = require('gulp-match'),
    log = gutil.log,
    color = gutil.colors,
    tildify = require('tildify'),
    EOL = require('os').EOL,
    config = require('./config');

function requireTask() {
    var args = arguments;
    return function (name) {
        var task = require('./tasks/' + name);
        return task.apply(task, args);
    };
}

function filterSymlinks() {
    function matching(file) {
        return gmatch(file, function (file) {
            var symlink = getSymlinkPath(file);
            // fs.lstat(symlink, function (err, stats) {
            //
            // });
            // console.log(stats);


            return true;
        });
    }

    return through.obj(function (file, enc, cb) {
        if (matching(file)) {
            this.push(file);
        }

        return cb();
    });
    // var symlink = getSymlinkPath(file);
    //
    // fs.lstat(symlink, function (err, stats) {
    //     if (!err && stats && stats.isSymbolicLink) {
    //         console.log(symlink, ':', stats.isSymbolicLink());
    //         cb(err, file);
    //     } else {
    //         cb(null, file);
    //     }
    // });
    //
    //

    // var promise = new Promise(function (resolve, reject) {
    //     fs.stat(path, function (err, stats) {
    //         if (!err && stats) return resolve(stats);
    //         return reject(err);
    //     });
    // });
    //
    // return promise
}

function getSymlinkPath(file) {
    return path.resolve(config.paths.home, file.relative);
}

function logPaths(file, cb) {
    // gutil.log.apply(this, arguments);
    log(file.path);
    if (cb) cb(null, file);
}

console.log = function() {
    this._stdout.write(util.format.apply(this, arguments) + EOL);
};

console.error = function() {
    this._stderr.write(color.red(util.format.apply(this, arguments)) + EOL);
};

module.exports = {
    log: log,
    color: color,
    requireTask: requireTask,
    filterSymlinks: filterSymlinks,
    logPaths: logPaths,
    tildify: tildify
};



// childProcess = require('child_process'),
// function exec(cmd) {
//     var promise = new Promise(function (resolve, reject) {
//         log('`' + color.white(cmd) + '`');
//         childProcess.exec(cmd, function (error, stdout, stderr) {
//             // if (error) reject(error);
//             if (stderr) {
//                 console.error(stderr);
//                 reject(stderr);
//             }
//             if (stdout) {
//                 console.log(stdout);
//                 resolve(stdout);
//             }
//         });
//     });
//
//     return promise;
// }
