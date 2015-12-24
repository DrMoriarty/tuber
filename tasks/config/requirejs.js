module.exports = function(grunt) {
    grunt.config.set('requirejs', {
        dev: {
            options: {
                baseUrl: "assets/",
                name: 'js/main',
                optimize: "none",//'none',//"uglify2",
                //wrap: true,
                paths: {
                    // Major libraries
                    jquery: '../vendor/jquery',
                    //underscore: '../vendor/underscore',
                    //backbone: '../vendor/backbone',
                    // Require.js plugins
                    rx: '../vendor/rx',
                },
                removeCombined: true,
                inlineText: true,
                useStrict: true,
                out: "build/main.js",
                waitSeconds: 200
            },
        }
    });

    grunt.loadNpmTasks('grunt-contrib-requirejs');
};
