'use strict';

var fs = require('fs'),
    os = require('os');

function configTask(g) {
    return function () {
        var promise = new Promise(function (resolve, reject) {
            fs.stat('config.json', function (err, stats) {
                if (!err) return resolve();

                return g.src('./config.template.json')
                    .pipe(g.plugins.prompt.confirm({
                        message: 'Create new configuration',
                        default: true
                    }))
                    .pipe(g.plugins.rename('./config.json'))
                    .pipe(g.dest('./'))
                    .on('end', resolve)
                    .on('error', reject);
            });
        });

        return promise.then(function () {
            var configPath = fs.realpathSync('config.json');
                // configFile = require(configPath);

            g.utils.log('Using configuration', g.utils.color.magenta(g.utils.tildify(configPath)));
        });
    };
}

module.exports = configTask;
