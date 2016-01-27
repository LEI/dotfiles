'use strict';

var _ = require('lodash'),
    gulp = require('gulp'),
    plugins = require('./plugins'),
    utils = require('./utils'),
    config = require('./config');

var G = _.extend(gulp, {
    plugins: plugins,
    utils: utils
});

config(G).then(function (cfg) {
    console.log('>>>>>>>>>>>>>>>>>>>>>>>>cfg', cfg);

    G.config = cfg;
    require('./sequence')(G);
});
