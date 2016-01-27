'use strict';

var run = require('run-sequence');

function sequence(G) {
    var Task = G.utils.requireTask(g);

    // Define tasks order

    G.task('git', Task('git'));

    G.task('symlink', Task('symlink'));

    G.task('unlink', Task('unlink'));

    // G.task('end', G.plugins.shell.task('ls ~/ | grep vim', { verbose: true }));

    G.task('default', function (cb) {
        run('git', 'symlink', cb);
    });

    G.task('undo', function (cb) {
        run('unlink', cb);
    });
}

module.exports = sequence;
