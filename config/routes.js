/**
 * Route Mappings
 * (sails.config.routes)
 *
 * Your routes map URLs to views and controllers.
 *
 * If Sails receives a URL that doesn't match any of the routes below,
 * it will check for matching files (images, scripts, stylesheets, etc.)
 * in your assets directory.  e.g. `http://localhost:1337/images/foo.jpg`
 * might match an image file: `/assets/images/foo.jpg`
 *
 * Finally, if those don't match either, the default 404 handler is triggered.
 * See `api/responses/notFound.js` to adjust your app's 404 logic.
 *
 * Note: Sails doesn't ACTUALLY serve stuff from `assets`-- the default Gruntfile in Sails copies
 * flat files from `assets` to `.tmp/public`.  This allows you to do things like compile LESS or
 * CoffeeScript for the front-end.
 *
 * For more information on configuring custom routes, check out:
 * http://sailsjs.org/#!/documentation/concepts/Routes/RouteTargetSyntax.html
 */

module.exports.routes = {

    /***************************************************************************
     *                                                                          *
     * Make the view located at `views/homepage.ejs` (or `views/homepage.jade`, *
     * etc. depending on your default view engine) your home page.              *
     *                                                                          *
     * (Alternatively, remove this and add an `index.html` file in your         *
     * `assets` directory)                                                      *
     *                                                                          *
     ***************************************************************************/

    '/': {
        view: 'homepage'
    },
    
    'get /login': {
        view: 'login'
    },

    'post /login': 'AuthController.login',
    
    '/logout': 'AuthController.logout',

    'get /signup': {
        view: 'signup'
    },

    'post /recovery': 'AuthController.generatePasswordRecovery',
    'get /recovery': 'AuthController.usePasswordRecovery',
    'get /auth/facebook': 'AuthController.loginFb',
    'get /auth/facebook/callback': 'AuthController.loginFbCallback',
    'get /install': 'AuthController.install',

    'get /braintree/token': 'BraintreeController.clientToken',
    '/braintree/transaction': 'BraintreeController.transaction',

    'get /search/route': 'SearchController.searchRoute',
    'get /search/parcel': 'SearchController.searchParcel',
    'get /search/parcelEllipse': 'SearchController.searchParcelInEllipse',
    'get /search/lastMessages': 'SearchController.messages',
    '/tracking': 'TrackingController.track',

    'get /admin': 'AdminController.main',
    'get /admin/city': 'AdminController.city',
    'get /admin/city/:id': 'AdminController.city',
    'get /admin/country': 'AdminController.country',
    'get /admin/country/:id': 'AdminController.country',
    'get /admin/parcel': 'AdminController.parcel',
    'get /admin/parcel/:id': 'AdminController.parcel',
    'get /admin/person': 'AdminController.person',
    'get /admin/person/:id': 'AdminController.person',
    'get /admin/route': 'AdminController.route',
    'get /admin/route/:id': 'AdminController.route',
    'get /admin/carrier': 'AdminController.carrier',
    'get /admin/carrier/:id': 'AdminController.carrier',
    'get /admin/sender': 'AdminController.sender',
    'get /admin/sender/:id': 'AdminController.sender'

    /***************************************************************************
     *                                                                          *
     * Custom routes here...                                                    *
     *                                                                          *
     * If a request to a URL doesn't match any of the custom routes above, it   *
     * is matched against Sails route blueprints. See `config/blueprints.js`    *
     * for configuration options and examples.                                  *
     *                                                                          *
     ***************************************************************************/

};
