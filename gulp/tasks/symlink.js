'use strict';

var vfs = require('vinyl-fs'),
    map = require('map-stream');

function symlinkTask(g) {
    return function () {
        return vfs.src(g.config.paths.symlinks + '/*', { dot: true })
            // .pipe(map(g.utils.filterSymlinks))
            .pipe(g.utils.filterSymlinks())
            // .pipe(vfs.symlink(g.config.paths.home))
            .pipe(map(g.utils.logPaths));
    };
}

module.exports = symlinkTask;
