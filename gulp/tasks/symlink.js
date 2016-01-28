'use strict';

var fs = require('fs'),
    _ = require('lodash'),
    async = require('async'),
    gulp = require('gulp'),
    prompt = require('gulp-prompt'),
    gutil = require('gulp-util'),
    utils = require('../utils'),
    config = require('../config');

module.exports = function symlink() {
    var srcGlob = _.values(_.mapValues(config.paths.symlinks, 'src'));
    // console.log(srcGlob);
    //     vp = utils.vp(),
    //     paths = [];

    return gulp.src(srcGlob, { dot: true })
        // .pipe(gutil.buffer(function (err, files) {
        //     files.forEach(function (file) {
        //         paths.push(file.path);
        //     });
        // }))
        // .pipe(vp)
        .pipe(utils.logStream)
        // .pipe(prompt.prompt({
        //     type: 'checkbox',
        //     name: 'paths',
        //     message: 'Create symbolic link?',
        //     choices: _.map(vp.paths, utils.tildify)
        // }, function (res) {
        //     console.log(res, vp.paths);
        // }));
    /*
    function doSymlink(paths) { // dest?
        return new Promise(function (resolve, reject) {
            gulp.src(paths)
                .pipe(prompt.prompt({
                    type: 'checkbox',
                    name: 'src',
                    message: 'Create symbolic link?',
                    choices: _.map(paths, utils.tildify)
                }, function (res) {
                    //vfs.symlink
                    if (res.src.length > 0) {
                        res.src.forEach(function (src) {
                            utils.symlink(src);
                        });
                    }
                }))
                // .pipe(map(function (file, cb) {
                //     // utils.isSymlink(file.path).then(function (isSymlink) {
                //         utils.log(file.path);
                //         if (cb) cb(null, file);
                //     // });
                // }))
                .on('end', resolve)
                .on('error', reject);
        });
    }

    var task = new Promise(function (resolve, reject) {
        var vp = utils.vp();
        gulp.src(srcGlob, { dot: true })
            // .pipe(utils.vp(doSymlink));
            .pipe(vp)
            .pipe(utils.logStream)
            .on('end', function () {
                doSymlink(vp.paths).then(resolve).catch(reject);
            });
            // .pipe(utils.vp(doSymlink));
    });

    return task;*/




    /*var results = {};

    function iterator(item, key, cb) {
        utils.lstat(item.dest).then(function (stats) {
            results[item.dest] = {
                stats: stats,
                isFile: stats.isFile(),
                isDirectory: stats.isDirectory(),
                isSymlink: stats.isSymbolicLink()
            };

            cb();
        }, cb);
    }

    var promise = new Promise(function (resolve, reject) {
        async.forEachOf(config.paths.symlinks, iterator, function (err) {
            if (err) return reject(err);
            utils.log(results);
            resolve(results);
        })
    });

    return promise;*/




    // var p = paths.reduce(function (promise, glob) {
    //     return promise.then(function () {
    //         return utils.isSymlink(glob.dest).then(function (isSymlink) {
    //             utils.log(glob.dest, isSymlink);
    //             // return isSymlink;
    //         });
    //     });
    // }, Promise.resolve());


    // var filePath = '/Users/LEI/.vim/bundle';
    // return utils.isSymlink(filePath).then(function (isSymlink) {
    //     utils.log(filePath, 'is symlink ~>', isSymlink);
    //     // resolve(filePath);
    // });

    // return gulp.src(''); // <- config.paths.symlinks.toArguments('dest')
};
