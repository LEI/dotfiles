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
