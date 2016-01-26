'use strict';

var map = require('map-stream');

function gitTask(g) {
    var commands = [
        'git pull',
        'git submodule init',
        'git submodule update',
        'git submodule status'
    ];

    // return g.src('.gitmodules')
    //     .pipe(map(g.utils.logPaths));

    return g.plugins.shell.task(commands, { verbose: true });
}

module.exports = gitTask;
