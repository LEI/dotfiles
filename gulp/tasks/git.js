'use strict';

var gulp = require('gulp'),
    shell = require('gulp-shell');

var commands = [
    'git pull',
    'git submodule init',
    'git submodule update',
    'git submodule status'
];

module.exports = shell.task(commands, {
    verbose: true
});
