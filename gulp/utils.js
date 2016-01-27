'use strict';

var fs = require('fs'),
    cp = require('child_process'),
    // colors = require('chalk'),
    through = require('through2'),
    gutil = require('gulp-util');

var utils = {

    log: function () {
        gutil.log.apply(this, arguments);
    },

    error: function () {
        gutil.log.apply(this, arguments);
    },

    fileExists: function (filePath) {
        return new Promise(function (resolve, reject) {
            fs.lstat(filePath, function (err, stats) {
                if (err) reject(err);
                else resolve(stats);
            });
        });
    },

    isSymlink: function (filePath) {
        return utils.fileExists(filePath)
            .then(function (stats) {
                return stats.isSymbolicLink();
            })
            .catch(function (error) {
                // throw error;
                return null;
            });
    },

    vp: function (callback) {
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

    exec: function (cmd) {
        var promise = new Promise(function (resolve, reject) {
            cp.exec(cmd, function (error, stdout, stderr) {
                if (error) throw error;
                if (stderr) reject(stderr);
                if (stdout) resolve(stdout);
            });
        });

        return promise;
    }

};

module.exports = utils;
