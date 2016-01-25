var gulp = require('gulp'),
    plugins = require('gulp-load-plugins')(),
    run = require('run-sequence'),
    utils = require('./utils'),
    task = utils.getTask(gulp, plugins, utils);

gulp.task('setup', function () {
    utils.exec('ls ~/ | grep vim');
});

gulp.task('symlink', task('symlink'));

gulp.task('default', function (cb) {
    run('symlink', 'setup', cb);
    // gulp.watch('src/sass/**/*.{sass,scss}', ['sass']);
});
