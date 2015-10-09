"""
 User.js

 @description :: TODO: You might write a short summary of how this model works and what it represents here.
 @docs        :: http://sailsjs.org/#!documentation/models
"""

bcrypt = require 'bcrypt'

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
        address2: 
            type: 'string'
            required: true
        zip: 
            type: 'string'
            required: true
        city:
            type: 'string'
            required: true
        country:
            type: 'string'
            required: true
        phone: 
            type: 'string'
            required: true
        birthdate: 'date'
        email:
            type: 'email'
            unique: true
        fbId: 
            type: 'string'
            unique: true
        login:
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
        # fields for drivers
        vehicleType: 'string'
        vehicleNum: 
            type: 'number'
            defaultsTo: 0
        maxLength:
            type: 'number'
            defaultsTo: 0
        maxWidth:
            type: 'number'
            defaultsTo: 0
        maxDepth:
            type: 'number'
            defaultsTo: 0
        maxWeight:
            type: 'number'
            defaultsTo: 0
        averageSpeed:
            type: 'number'
            defaultsTo: 0
        averageDayDistance:
            type: 'number'
            defaultsTo: 0
        pricePerKm:
            type: 'number'
            defaultsTo: 0
        defaultPrice:
            type: 'number'
            defaultsTo: 0
        coverageDistance:
            type: 'number'
            defaultsTo: 0
        toJSON: ->
            obj = this.toObject()
            delete obj.password
            return obj

    beforeCreate: (user, cb) ->
        if not user.login?
            if user.email
                user.login = user.email
            else if user.fbId
                user.login = user.fbId
        if user.password?
            bcrypt.genSalt 10, (err, salt) ->
                bcrypt.hash user.password, salt, (err, hash) ->
                    if (err)
                        console.log err
                        cb err
                    else
                        user.password = hash
                        cb null, user
        else
            cb null, user
