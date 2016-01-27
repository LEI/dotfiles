'use strict';

var gulp = require('gulp'),
    shell = require('gulp-shell'),
    utils = require('../utils');

module.exports = function git() {
    var commands = [
        'git pull',
        'git submodule init',
        'git submodule update',
        'git submodule status'
    ];

    return shell.task(commands, { verbose: true });

    // commands.forEach(function (cmd) {
    //     utils.log('>', cmd);
    //     utils.exec(cmd).then(function (res) {
    //         utils.log('exec res', res);
    //     }, function (err) {
    //         utils.error('exec err', err);
    //     });
    // })
};
