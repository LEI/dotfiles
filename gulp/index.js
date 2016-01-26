'use strict';

var _ = require('lodash'),
    gulp = require('gulp'),
    plugins = require('gulp-load-plugins')(),
    config = require('./config'),
    utils = require('./utils');

// var config = utils.loadConfig();

var g = _.extend(gulp, {
    plugins: plugins,
    config: config,
    utils: utils
});

// Define tasks order
require('./sequence')(g);
