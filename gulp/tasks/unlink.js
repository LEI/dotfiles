'use strict';

var path = require('path'),
    // vfs = require('vinyl-fs'),
    map = require('map-stream');

function unlinkTask(g) {
    var commands = [];

    function unlink(file, cb) {
        var symlink = g.utils.getSymlinkPath(file);
        commands.push('unlink ' + symlink);

        cb(null, file);
    }

    return function () {
        return g.src(g.config.paths.symlinks + '/*', { dot: true })
            // .pipe(g.plugins.util.buffer(function (err, files) {
            //     files.forEach(function (file) {
            //         var symlink = path.resolve(g.config.paths.home, file.relative);
            //         commands.push('unlink ' + symlink);
            //     });
            // }))
            .pipe(map(unlink))
            // .pipe(g.plugins.shell([
            //     'echo LOL <%= file.path %>'
            // ]));
            .pipe(g.plugins.shell(commands, { verbose: true }));
    };
}

module.exports = unlinkTask;
