"""
 * Bootstrap
 * (sails.config.bootstrap)
 *
 * An asynchronous bootstrap function that runs before your Sails app gets lifted.
 * This gives you an opportunity to set up your data model, run jobs, or perform some special logic.
 *
 * For more information on bootstrapping your app, check out:
 * http://sailsjs.org/#!/documentation/reference/sails.config/sails.config.bootstrap.html
"""

module.exports.bootstrap = (cb) ->

    GeoService.zipGeoFromGoogle '30166', 'Germany', (lat, lng) ->
        console.log('Google said', lat, lng)

    GeoService.zipGeoFromOSM '30166', 'Germany', (lat, lng) ->
        console.log('OSM said', lat, lng)

    Person.find({}).exec (err, persons) ->
        if err?
            console.log err
            return
        for person in persons
            if not person.countryCode?
                Person.update({id: person.id}, {country: person.country}).exec (err, result) ->
                    console.log err if err?
    User.find({}).exec (err, users) ->
        for user in users
            if not user.countryCode?
                User.update({id: user.id}, {country: user.country}).exec (err, result) ->
                    console.log err if err?
                
    # It's very important to trigger this callback method when you are finished
    # with the bootstrap!  (otherwise your server will never lift, since it's waiting on the bootstrap)
    cb()

