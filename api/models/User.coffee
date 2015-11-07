"""
 User.js

 @description :: TODO: You might write a short summary of how this model works and what it represents here.
 @docs        :: http://sailsjs.org/#!documentation/models
"""

geocoder = require 'geocoder'
bcrypt = require 'bcrypt'
util = require 'util'

updateCoordinates = (user, data, cb) ->
    console.log 'User coordinates', util.inspect(data, {showHidden: false, depth: null})
    if data.results? and data.results.length > 0
        res = data.results[0]
        if res.geometry?.location?
            if cb?
                user.latitude = res.geometry.location.lat
                user.longitude = res.geometry.location.lng
                cb (user)
            else
                User.update user.id, {latitude: res.geometry.location.lat, longitude: res.geometry.location.lng}, (err, updatedRecord) ->
                    if err?
                        console.log 'Error', err
                    else
                        console.log 'Update user', updatedRecord
        else
            console.log 'Invalid geocoding result', util.inspect(data, {showHidden: false, depth: null})
    else
        console.log 'Invalid geocoding result', util.inspect(data, {showHidden: false, depth: null})

checkUserCoordinates = (user, cb) ->
    console.log 'New user records', user
    if user.zip?
        address = user.zip
        if user.country?
            address = address + ', ' + user.country
        geocoder.geocode address, (err, data) ->
            if not err and data
                updateCoordinates user, data, (u) ->
                    cb(u)
    else
        cb(user)

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
        toJSON: ->
            obj = this.toObject()
            delete obj.password
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
                        cb null, user
        else
            delete user.password
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
                        checkUserCoordinates user, (u) ->
                            cb null, u
        else
            delete user.password
            checkUserCoordinates user, (u) ->
                cb null, u

    afterCreate: (user, cb) ->
        if user.zip?
            address = user.zip
            if user.country?
                address = address + ', ' + user.country
            geocoder.geocode address, (err, data) ->
                if not err and data
                    updateCoordinates this, data


