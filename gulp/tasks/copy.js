'use strict';

var gulp = require('gulp'),
    map = require('map-stream'),
    utils = require('../utils');

module.exports = function copy() {

    return gulp.src('./.vim/*')
        .pipe(map(function (file, cb) {
            utils.log(file.path);
            if (cb) cb(null, file);
        }));
};
