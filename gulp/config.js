'use strict';

var os = require('os'),
    _ = require('lodash');

var config = {

    platform: os.platform(),
    homedir: os.homedir(),

    paths: {
        symlinks: [
            {
                src: 'symlinks/*',
                dest: '$HOME/'
            },
            {
                src: '.vim/*',
                dest: '$HOME/.vim/'
            }
        ]
    }

};

// config = _.extend(require('../cfg'), config);

module.exports = config;

// if (e.code !== 'MODULE_NOT_FOUND') {
//     // Re-throw not "Module not found" errors
//     throw e;
// }
// if (e.message.indexOf('\'express\'') === -1) {
//     // Re-throw not found errors for other modules
//     throw e;
// }
