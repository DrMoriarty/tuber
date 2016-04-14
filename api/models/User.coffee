"""
 User.js

 @description :: TODO: You might write a short summary of how this model works and what it represents here.
 @docs        :: http://sailsjs.org/#!documentation/models
"""

bcrypt = require 'bcrypt'
util = require 'util'
async = require 'async'

module.exports = 
	_config: 
        shortcuts: false
    attributes:
        firstname: 
            type: 'string'
            required: true
        lastname: 
            type: 'string'
            required: true
        fullname: ->
            @firstname + ' ' + @lastname
        company: 'string'
        vat: 'string'
        address1: 
            type: 'string'
            required: true
            defaultsTo: ''
        address2: 
            type: 'string'
            required: true
            defaultsTo: ''
        zip: 
            type: 'string'
            required: true
            defaultsTo: ''
        city:
            type: 'string'
            required: true
            defaultsTo: ''
        country:
            type: 'string'
            required: true
            defaultsTo: ''
        countryCode:
            type: 'string'
        phone: 
            type: 'string'
            required: true
            defaultsTo: ''
        birthdate: 'date'
        email:
            type: 'email'
            unique: true
        fbId: 
            type: 'string'
            unique: true
        password: 
            type: 'string'
            minLength: 5
        passwordCopy:
            type: 'string'
        photo: 'string'
        driver: 
            type: 'boolean'
            defaultsTo: false
        admin: 
            type: 'boolean'
            defaultsTo: false
        latitude:
            type: 'float'
            defaultsTo: 0
        longitude:
            type: 'float'
            defaultsTo: 0
        # fields for drivers
        vehicleType: 'string'
        vehicleNum: 
            type: 'integer'
            defaultsTo: 0
        maxLength:
            type: 'integer'
            defaultsTo: 20
        maxWidth:
            type: 'integer'
            defaultsTo: 20
        maxDepth:
            type: 'integer'
            defaultsTo: 20
        maxWeight:
            type: 'integer'
            defaultsTo: 1
        parcelsPerDay:
            type: 'integer'
            defaultsTo: 0
        workDay0: 
            type: 'boolean'
            defaultsTo: true
        workDay1:
            type: 'boolean'
            defaultsTo: true
        workDay2:
            type: 'boolean'
            defaultsTo: true
        workDay3:
            type: 'boolean'
            defaultsTo: true
        workDay4:
            type: 'boolean'
            defaultsTo: true
        workDay5:
            type: 'boolean'
            defaultsTo: true
        workDay6:
            type: 'boolean'
            defaultsTo: true
        averageSpeed:
            type: 'float'
            defaultsTo: 0
        averageDayDistance:
            type: 'float'
            defaultsTo: 0
        pricePerKm:
            type: 'float'
            defaultsTo: 0
        defaultPrice:
            type: 'float'
            defaultsTo: 0
        coverageDistance:
            type: 'float'
            defaultsTo: 0
        balance:
            type: 'float'
            defaultsTo: 0
        recoveryHash:
            type: 'string'
        getPrice: (parcel) ->
            #if @defaultPrice > 0 then @defaultPrice else @pricePerKm * parcel.pathLength
            return DepartureService.priceCalc this, parcel
        bankAccount: 'string'
        bankCode: 'string'
        bankName: 'string'
        bankClientName: 'string'
        lang:
            type: 'string'
            defaultsTo: 'en'
        toJSON: ->
            obj = this.toObject()
            delete obj.password
            delete obj.recoveryHash
            return obj

    beforeCreate: (user, cb) ->
        async.series( [
            (callback) ->
                if user.password? and user.password.length > 0
                    user.passwordCopy = user.password  # DEBUG !!!
                    bcrypt.genSalt 10, (err, salt) ->
                        bcrypt.hash user.password, salt, (err, hash) ->
                            if (err)
                                console.log err
                                callback err, null
                            else
                                user.password = hash
                                callback null, user
                else
                    callback null, user
            (callback) ->
                if user.zip? and user.country?
                    GeoService.zipGeo user.zip, user.country, (lat, lng) ->
                        user.latitude = lat
                        user.longitude = lng
                        GeoService.countryCode user.country, (code) ->
                            user.countryCode = code
                            callback null, user
                else
                    callback null, user
        ], (err, result) ->
            cb null, user
        )

    beforeUpdate: (user, cb) ->
        async.series( [
            (callback) ->
                if user.password? and user.password.length > 0
                    user.passwordCopy = user.password  # DEBUG !!!
                    #console.log 'Change password', user.password, 'for', user
                    bcrypt.genSalt 10, (err, salt) ->
                        bcrypt.hash user.password, salt, (err, hash) ->
                            if (err)
                                console.log err
                                callback err, null
                            else
                                user.password = hash
                                callback null, user
                else
                    callback null, user
            (callback) ->
                if user.zip? and user.country?
                   GeoService.zipGeo user.zip, user.country, (lat, lng) ->
                        user.latitude = lat
                        user.longitude = lng
                        callback null, user
                else
                    callback null, user
            (callback) ->
                if user.country?
                    GeoService.countryCode user.country, (code) ->
                        user.countryCode = code
                        callback null, user
                else
                    callback null, user
        ], (err, result) ->
            cb null, user
        )

    afterCreate: (object, cb) ->
        cb()
        LogService.saveLog 'Create', 'User', JSON.stringify(object)
        MailingService.processEvent object.email, 'registrationComplete', object.lang

    afterUpdate: (object, cb) ->
        cb()
        LogService.saveLog 'Update', 'User', JSON.stringify(object)

    afterDestroy: (object, cb) ->
        cb()
        LogService.saveLog 'Delete', 'User', JSON.stringify(object)
