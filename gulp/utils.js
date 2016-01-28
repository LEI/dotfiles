'use strict';

var fs = require('fs'),
    cp = require('child_process'),
    // colors = require('chalk'),
    vfs = require('vinyl-fs'),
    map = require('map-stream'),
    through = require('through2'),
    tildify = require('tildify'),
    gutil = require('gulp-util');

var utils = {

    log: function () {
        gutil.log.apply(this, arguments);
    },

    logStream: map(function (file, cb) {
        utils.log(file.path);
        if (cb) cb(null, file);
    }),

    error: function () {
        gutil.log.apply(this, arguments);
    },

    exec: function (cmd) {
        var promise = new Promise(function (resolve, reject) {
            cp.exec(cmd, function (error, stdout, stderr) {
                if (error) throw error;
                if (stderr) reject(stderr);
                if (stdout) resolve(stdout);
            });
        });

        return promise;
    },

    lstat: function (filePath) {
        return new Promise(function (resolve, reject) {
            fs.lstat(filePath, function (err, stats) {
                if (err) reject(err);
                else resolve(stats);
            });
        });
    },

    isSymlink: function (filePath) {
        return utils.lstat(filePath)
            .then(function (stats) {
                return stats.isSymbolicLink();
            })
            .catch(function (error) {
                // utils.error(error);
                return null;
            });
    },

    stringify: function (obj) {
        return JSON.stringify(obj, null, 2);
    },

    symlink: vfs.symlink,

    tildify: tildify,

    // filter: function (condition) {
    //     return through.obj(function (file, enc, cb) {
    //         if (condition(file)) this.push(file);
    //         return cb();
    //     });
    // },

    vp: function (callback/*, condition*/) {
        var stream = through.obj(function (file, enc, cb) {
            this.paths.push(file.path);

            if (callback) {
                callback(file.path).then(function () {
                    cb(null, file);
                }).catch(cb);
            } else {
                cb(null, file);
            }
        });

        stream.paths = [];

        return stream;
    },

    prettify: function (file) {
        var p = fs.realpathSync(file);
        return tildify(p);
    }

};

module.exports = utils;
