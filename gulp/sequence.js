'use strict';

var run = require('run-sequence');

function sequence(g) {
    var Task = g.utils.requireTask(g);

    g.task('config', Task('config'));

    g.task('git', Task('git'));

    g.task('symlink', ['config'], Task('symlink'));

    g.task('unlink', ['config'], Task('unlink'));

    // g.task('end', g.plugins.shell.task('ls ~/ | grep vim', { verbose: true }));

    g.task('default', function (cb) {
        run('git', 'symlink', cb);
    });

    g.task('undo', function (cb) {
        run('unlink', cb);
    });
}

module.exports = sequence;
