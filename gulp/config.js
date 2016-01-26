'use strict';

var os = require('os'),
    path = require('path'),
    _ = require('lodash'),
    platform = os.platform(),
    home = os.homedir();

function config() {
    try {
        var config = require('../config.json');
    } catch (err) {
        console.error(path.normalize('../config.json'), 'Not Found');
    }

    // Configuration defaults
    return _.merge({
        os: platform,
        paths: {
           home: home,
           // copy: [],
           symlinks: [
               {
                   src: 'symlinks/*',
                   dest: home + '/'
               },
               {
                   src: '.vim/*',
                   dest: home + '/.vim/'
               }
           ]
        }
    }, config);
}

module.exports = config();
