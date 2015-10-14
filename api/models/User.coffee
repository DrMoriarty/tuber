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
        toJSON: ->
            obj = this.toObject()
            delete obj.password
            return obj

    beforeCreate: (user, cb) ->
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
