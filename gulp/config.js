'use strict';

var os = require('os'),
    _ = require('lodash'),
    colors = require('chalk'),
    utils = require('./utils'),
    platform = os.platform(),
    homedir = os.homedir();

module.exports = config();

function config() {
    var configFile = 'config.json',
        configPath = utils.prettify(configFile);

    // Default settings
    var config = {
        platform: platform,
        paths: {
            symlinks: {}
        }
    };

    try {
        // Load JSON configuration file
        var jsonConfig = require('../' + configFile);
        config = _.merge(jsonConfig, config);

        utils.log('Using configuration', colors.magenta(configPath));
    } catch (err) {
        utils.error('Failed to load configuration', colors.magenta(configPath), err);
    }

    // Replace path variables ($HOME)
    config.paths = _.mapValues(config.paths, function (value, key, object) {
        return _.mapValues(value, function (v, k, o) {
            return _.mapValues(v, function (path) {
                return path.replace('$HOME', homedir);
            });
        });
    });

    // if (debug) utils.log(utils.stringify(config));

    return config;
}
