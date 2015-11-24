"""
 User.js

 @description :: TODO: You might write a short summary of how this model works and what it represents here.
 @docs        :: http://sailsjs.org/#!documentation/models
"""

bcrypt = require 'bcrypt'
util = require 'util'

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
            defaultsTo: 0
        maxWidth:
            type: 'integer'
            defaultsTo: 0
        maxDepth:
            type: 'integer'
            defaultsTo: 0
        maxWeight:
            type: 'integer'
            defaultsTo: 0
        parcelsPerDay:
            type: 'integer'
            defaultsTo: 0
        workDay0: 
            type: 'boolean'
            defaultsTo: false
        workDay1:
            type: 'boolean'
            defaultsTo: false
        workDay2:
            type: 'boolean'
            defaultsTo: false
        workDay3:
            type: 'boolean'
            defaultsTo: false
        workDay4:
            type: 'boolean'
            defaultsTo: false
        workDay5:
            type: 'boolean'
            defaultsTo: false
        workDay6:
            type: 'boolean'
            defaultsTo: false
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
        recoveryHash:
            type: 'string'
        toJSON: ->
            obj = this.toObject()
            delete obj.password
            delete obj.recoveryHash
            return obj

    beforeCreate: (user, cb) ->
        if user.password? and user.password.length > 0
            bcrypt.genSalt 10, (err, salt) ->
                bcrypt.hash user.password, salt, (err, hash) ->
                    if (err)
                        console.log err
                        cb err
                    else
                        user.password = hash
                        GeoService.zipGeo user.zip, user.country, (lat, lng) ->
                            user.latitude = lat
                            user.longitude = lng
                            cb null, user
        else
            delete user.password
            GeoService.zipGeo user.zip, user.country, (lat, lng) ->
                user.latitude = lat
                user.longitude = lng
                cb null, user

    beforeUpdate: (user, cb) ->
        if user.password? and user.password.length > 0
            #console.log 'Change password', user.password, 'for', user
            bcrypt.genSalt 10, (err, salt) ->
                bcrypt.hash user.password, salt, (err, hash) ->
                    if (err)
                        console.log err
                        cb err
                    else
                        user.password = hash
                        GeoService.zipGeo user.zip, user.country, (lat, lng) ->
                            user.latitude = lat
                            user.longitude = lng
                            cb null, user
        else
            delete user.password
            GeoService.zipGeo user.zip, user.country, (lat, lng) ->
                user.latitude = lat
                user.longitude = lng
                cb null, user

    afterCreate: (object, cb) ->
        LogService.saveLog 'Create', 'User', JSON.stringify(object)
        cb()

    afterUpdate: (object, cb) ->
        LogService.saveLog 'Update', 'User', JSON.stringify(object)
        cb()

    afterDestroy: (object, cb) ->
        LogService.saveLog 'Delete', 'User', JSON.stringify(object)
        cb()
