'use strict';

var dir = require('require-dir'),
    run = require('run-sequence'),
    gulp = require('gulp'),
    gutil = require('gulp-util');

module.exports = (function sequence() {
    var tasks = dir('./tasks');

    gulp.task('git', tasks.git);
    gulp.task('copy', tasks.copy);
    gulp.task('symlink', tasks.symlink);

    gulp.task('default', ['git'], function (cb) {
        run('symlink', 'copy', cb);
    });
})();
