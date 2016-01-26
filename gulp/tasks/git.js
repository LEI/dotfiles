'use strict';

function gitTask(g) {
    var commands = [
        'git pull',
        'git submodule init',
        'git submodule update',
        'git submodule status'
    ];

    return g.plugins.shell.task(commands, { verbose: true });
}

module.exports = gitTask;
