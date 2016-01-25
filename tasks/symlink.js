module.exports = function (gulp, plugins, utils) {
    var map = require('map-stream'),
        fs = require('vinyl-fs');

    return function () {
        return fs.src(['./files/*', './files/.*'])
            .pipe(fs.symlink('/', { cwd: '~' }))
            .pipe(map(utils.log));
        ;
    };
};
