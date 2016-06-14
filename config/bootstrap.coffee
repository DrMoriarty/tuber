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
#{ObjectId} = require('mongodb')

module.exports.bootstrap = (cb) ->

    Person.find({countryCode: {$exists: false}}).exec (err, persons) ->
        if err?
            console.log err
            return
        for person in persons
            Person.update({id: person.id}, {country: person.country}).exec (err, result) ->
                console.log err if err?

    User.find({countryCode: {$exists: false}}).exec (err, users) ->
        for user in users
            User.update({id: user.id}, {country: user.country}).exec (err, result) ->
                console.log err if err?

    User.find({login: {$exists: false}}).exec (err, users) ->
        for user in users
            if user.driver
                User.update({id: user.id}, {login: 'driver_'+user.email}).exec (err, result) ->
                    console.log err if err?
            else
                User.update({id: user.id}, {login: user.email}).exec (err, result) ->
                    console.log err if err?

    Log.find({object: {$exists: false}}).exec (err, logs) ->
        for log in logs
            try
                obj = JSON.parse(log.argument)
                objectId = obj.id
                Log.update({id: log.id}, {object: objectId}).exec (err, result) ->
                    console.log err if err?
            catch err
                # do nothing

    User.find({driverAcceptTime: {$exists: false}}).exec (err, drivers) ->
        for driver in drivers
            User.update({id: driver.id}, {driverAcceptTime: 12}).exec (err, result) ->
                console.log err if err?

    defaultAdmin = sails.config.tuber.defaultAdmin
    if defaultAdmin? and defaultAdmin.email?
        User.find({email: defaultAdmin.email, admin: true}).exec (err, users) ->
            if users? and users.length > 0
                console.log 'Check admin account: OK'
            else
                console.log 'Create default admin account'
                User.find({admin: true}).exec (err, admins) ->
                    console.log err if err
                    defaultAdmin.admin = true
                    User.create(defaultAdmin).exec (err, result) ->
                        if err
                            console.log 'Change admin cancelled'
                            console.log err
                        else
                            console.log 'New admin account', defaultAdmin.email
                            for lastAdmin in admins
                                User.destroy({id: lastAdmin.id}).exec (err, result) ->
                                    console.log err if err
    else
        console.log 'Can not create default admin user! Check file config/tuber.coffee'
                
    # It's very important to trigger this callback method when you are finished
    # with the bootstrap!  (otherwise your server will never lift, since it's waiting on the bootstrap)
    cb()

