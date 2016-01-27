'use strict';

var fs = require('fs'),
    gulp = require('gulp'),
    utils = require('../utils'),
    config = require('../config');

module.exports = function symlink() {
    var filePath = '/Users/LEI/.vim/bundle';
    return utils.isSymlink(filePath).then(function (isSymlink) {
        utils.log(filePath, 'is symlink ~>', isSymlink);
        // resolve(filePath);
    });

    // return gulp.src(''); // <- config.paths.symlinks.toArguments('dest')
};
