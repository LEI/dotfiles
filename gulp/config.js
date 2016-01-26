'use strict';

var os = require('os'),
    _ = require('lodash'),
    configFile = require('../config.json');


var config = _.merge({
    // Configuration defaults
    os: os.platform(),
    paths: {
        home: os.homedir(),
        symlinks: 'symlinks'
    }
}, configFile);

module.exports = config;
