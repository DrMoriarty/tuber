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

    'get /': 'SiteController.home',
    'get /faq': 'SiteController.faq',
    'get /registration': 'SiteController.registration',
    'get /parcel': 'SiteController.parcel',
    'get /price/:parcelId': 'SiteController.price',
    'get /dashboard': 'SiteController.dashboard',
    'get /confirmation/:parcelId': 'SiteController.confirmation',
    'get /payment/:requestId': 'SiteController.payment',
    'get /payment': 'SiteController.findPayment',
    'get /profile': 'SiteController.profile',
    'post /make/parcel': 'SiteController.makeParcel',
    
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
    'get /api/parcel/:parcelId/pdf': 'ParcelController.shipmentLabel',

    'get /braintree/token': 'BraintreeController.clientToken',
    '/braintree/transaction': 'BraintreeController.transaction',

    'all /search/driver': 'SearchController.searchDriver',
    'all /search/parcel': 'SearchController.searchParcel',
    //'get /search/parcelEllipse': 'SearchController.searchParcelInEllipse',
    'get /search/lastMessages': 'SearchController.messages',
    '/tracking': 'TrackingController.track',
    'all /accept/parcel/:parcelId/carrier/:driverId': 'SearchController.acceptDriver',
    'all /accept/carrier/parcel/:parcelId': 'SearchController.acceptParcel',

    'get /admin': 'AdminController.main',
    'get /admin/profile': 'AdminController.profile',
    'get /admin/profile/edit': 'AdminController.profileEdit',
    'get /admin/city': 'AdminController.cities',
    //'get /admin/city/:id': 'AdminController.city',
    'get /admin/country': 'AdminController.countries',
    //'get /admin/country/:id': 'AdminController.country',
    'get /admin/parcel': 'AdminController.parcels',
    'get /admin/parcel/new': 'AdminController.newParcel',
    'get /admin/parcel/:id': 'AdminController.parcel',
    'get /admin/person': 'AdminController.persons',
    'get /admin/person/new': 'AdminController.newPerson',
    'get /admin/person/:id': 'AdminController.person',
    'get /admin/route': 'AdminController.routes',
    'get /admin/route/:id': 'AdminController.route',
    'get /admin/carrier': 'AdminController.carriers',
    'get /admin/carrier/new': 'AdminController.newCarrier',
    'get /admin/carrier/:id': 'AdminController.carrier',
    'get /admin/sender': 'AdminController.senders',
    'get /admin/sender/new': 'AdminController.newSender',
    'get /admin/sender/:id': 'AdminController.sender',
    'get /admin/findcarriers/:id': 'AdminController.findCarriers',
    'get /admin/findparcels/:id': 'AdminController.findParcels',
    'all /admin/accept/parcel/:parcelId/carrier/:driverId': 'AdminController.acceptDriver',
    'all /admin/accept/carrier/:driverId/parcel/:parcelId': 'AdminController.acceptParcel',
    'get /admin/request': 'AdminController.requests',
    'get /admin/servertests': 'AdminController.serverTests',
    'all /admin/stresstest': 'AdminController.stressTest',
    'all /admin/logs': 'AdminController.logs',
    'all /dpd/getAuth': 'DpdController.getAuth',
    'all /dpd/storeOrders': 'DpdController.storeOrders',
    'all /dpd/getTrackingData': 'DpdController.getTrackingData',
    'all /dpd/getParcelLabelNumber': 'DpdController.getParcelLabelNumber',

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
