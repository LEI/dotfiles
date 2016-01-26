'use strict';

var run = require('run-sequence');

function runSequence(gulp) {
    var register = gulp.utils.requireTask(gulp);

    gulp.task('config', register('config'));

    gulp.task('git', register('git'));

    gulp.task('symlink', ['config'], register('symlink'));

    gulp.task('unlink', ['config'], register('unlink'));

    // gulp.task('end', gulp.plugins.shell.task('ls ~/ | grep vim', { verbose: true }));

    gulp.task('default', function (cb) {
        run('git', 'symlink', cb);
    });

    gulp.task('undo', function (cb) {
        run('unlink', cb);
    });
}

module.exports = runSequence;
