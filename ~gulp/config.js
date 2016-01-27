'use strict';

var _ = require('lodash'),
    os = require('os'),
    fs = require('fs'),
    path = require('path'),
    platform = os.platform(),
    home = os.homedir(),
    filePath = '../config.json';

var defaultConfig = {
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
};

function config(G) {
    var askConfig = new Promise(function (resolve, reject) {
        fs.stat(filePath, function (err, stats) {
            // TODO
            console.log(err, stats);
            if (!err) return resolve();

            return G.src('./config.template.json')
                .pipe(G.plugins.prompt.confirm({
                    message: 'Create new configuration',
                    default: true
                }))
                .pipe(G.plugins.rename('./config.json'))
                .pipe(G.dest('./'))
                .on('end', resolve)
                .on('error', reject);
        });
    }).then(function () {
        var configPath = fs.realpathSync('config.json');
            // configFile = require(configPath);

        G.utils.log('Using configuration', G.utils.color.magenta(G.utils.tildify(configPath)));
    });

    var promise = new Promise(function (resolve, reject) {
        askConfig.then(function () {
            var cfg = require(filePath);
            // Setting configuration defaults
            resolve(_.merge(defaultConfig, cfg));
        });
    });
        // try {
        //     var cfg = require(filePath);
        //     resolve(cfg);
        // } catch (error) {
        //     // var absPath = utils.normalize(__dirname, filePath);
        //     // error.message = error.message
        //     //     .replace(filePath, absPath)
        //     //     .replace('module', 'configuration');
        //     // throw error;
        //     console.log('!!!!!')
        //     G.task('config', G.utils.requireTask(G)('config'));
        //     console.log('??????')
        //     G.utils.run('config', function () {
        //         var cfg = require(filePath);
        //         resolve(cfg);
        //     });
        // }
    // }).then(function (cfg) {
    //     console.log('then', cfg);
    //     // Setting configuration defaults
    //     return _.merge(defaultConfig, cfg);
    // }, function (err) {
    //     console.error(err);
    // });

    return promise;
}

module.exports = config;
