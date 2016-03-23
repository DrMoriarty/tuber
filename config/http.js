/**
 * HTTP Server Settings
 * (sails.config.http)
 *
 * Configuration for the underlying HTTP server in Sails.
 * Only applies to HTTP requests (not WebSockets)
 *
 * For more information on configuration, check out:
 * http://sailsjs.org/#!/documentation/reference/sails.config/sails.config.http.html
 */

var moment = require('moment');
var device = require('express-device');

module.exports.http = {

  /****************************************************************************
  *                                                                           *
  * Express middleware to use for every Sails request. To add custom          *
  * middleware to the mix, add a function to the middleware config object and *
  * add its key to the "order" array. The $custom key is reserved for         *
  * backwards-compatibility with Sails v0.9.x apps that use the               *
  * `customMiddleware` config option.                                         *
  *                                                                           *
  ****************************************************************************/

    middleware: {

        passportInit    : require('passport').initialize(),
        passportSession : require('passport').session(),
        responseTime    : require('response-time')({suffix: false}),
        device          : device.capture(),

  /***************************************************************************
  *                                                                          *
  * The order in which middleware should be run for HTTP request. (the Sails *
  * router is invoked by the "router" middleware below.)                     *
  *                                                                          *
  ***************************************************************************/

        order: [
            'startRequestTimer',
            'responseTime',
            'cookieParser',
            'session',
            'passportInit',
            'passportSession',
            'myRequestLogger',
            'bodyParser',
            'handleBodyParserError',
            'compress',
            'methodOverride',
            'device',
            'mobileChecker',
            'langChecker',
            'poweredBy',
            '$custom',
            'router',
            'www',
            'favicon',
            '404',
            '500'
        ],

        mobileChecker: function (req, res, next) {
            //console.log('Device', req.device.type);
            //console.log('Host', req.host, sails.getBaseurl(), req.headers);
            var mobdev = req.device.type != 'desktop';
            m = req.param('m') || req.param('mobile');
            if(m) {
                req.mobile = (m == '1' || m == 'true');
            } else {
		        var host = req.headers['x-host'] || req.host;
		        //console.log('Host >>>', host);
                req.mobile = (host.indexOf('m.') == 0);
                if(host == 'packet24.com' && !req.mobile) {
                    req.redirect('http://m.packet24.com'+req.path);
                    return;
                }
            }
            //console.log('Set mobile', req.mobile);
            return next();
        },

        langChecker: function(req, res, next) {
            if(req.session.lang) {
                req.locale = req.session.lang;
            }
            return next();
        }

  /****************************************************************************
  *                                                                           *
  * Example custom middleware; logs each request to the console.              *
  *                                                                           *
  ****************************************************************************/

    // myRequestLogger: function (req, res, next) {
    //     console.log("Requested :: ", req.method, req.url);
    //     return next();
    // }


  /***************************************************************************
  *                                                                          *
  * The body parser that will handle incoming multipart HTTP requests. By    *
  * default as of v0.10, Sails uses                                          *
  * [skipper](http://github.com/balderdashy/skipper). See                    *
  * http://www.senchalabs.org/connect/multipart.html for other options.      *
  *                                                                          *
  ***************************************************************************/

    // bodyParser: require('skipper')

    },

  /***************************************************************************
  *                                                                          *
  * The number of seconds to cache flat files on disk being served by        *
  * Express static middleware (by default, these files are in `.tmp/public`) *
  *                                                                          *
  * The HTTP static cache is only active in a 'production' environment,      *
  * since that's the only time Express will cache flat-files.                *
  *                                                                          *
  ***************************************************************************/

    cache: 31557600000,

    customMiddleware: function(app) {
        app.locals.moment = moment;
    }
};
