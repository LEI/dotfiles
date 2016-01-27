'use strict';

var map = require('map-stream');

function gitTask(G) {
    var commands = [
        'git pull',
        'git submodule init',
        'git submodule update',
        'git submodule status'
    ];

    // return g.src('.gitmodules')
    //     .pipe(map(g.utils.logPaths));

    return G.plugins.shell.task(commands, { verbose: true });
}

module.exports = gitTask;
