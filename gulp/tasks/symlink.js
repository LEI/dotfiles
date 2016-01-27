'use strict';

var fs = require('fs'),
    gulp = require('gulp'),
    utils = require('../utils'),
    config = require('../config');

module.exports = function symlink() {
    var paths = config.paths.symlinks;

    var p = paths.reduce(function (promise, glob) {
        return promise.then(function () {
            return utils.isSymlink(glob.dest).then(function (isSymlink) {
                utils.log(glob.dest, isSymlink);
                // return isSymlink;
            });
        });
    }, Promise.resolve());

    return p;


    // var filePath = '/Users/LEI/.vim/bundle';
    // return utils.isSymlink(filePath).then(function (isSymlink) {
    //     utils.log(filePath, 'is symlink ~>', isSymlink);
    //     // resolve(filePath);
    // });

    // return gulp.src(''); // <- config.paths.symlinks.toArguments('dest')
};
