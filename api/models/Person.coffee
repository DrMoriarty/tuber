"""
 Person.js

 @description :: TODO: You might write a short summary of how this model works and what it represents here.
 @docs        :: http://sailsjs.org/#!documentation/models
"""
async = require 'async'

module.exports = 
    attributes:
        firstname: 
            type: 'string'
            required: true
        lastname: 
            type: 'string'
            required: true
        fullname: ->
            @firstname + ' ' + @lastname
        address1: 
            type: 'string'
            required: true
        address2:
            type: 'string'
            required: true
        zip: 
            type: 'string'
            defaultsTo: ''
        latitude:
            type: 'float'
            defaultsTo: 0
        longitude:
            type: 'float'
            defaultsTo: 0
        city:
            type: 'string'
            required: true
        country:
            type: 'string'
            required: true
        countryCode:
            type: 'string'
        phone:
            type: 'string'
            required: true
        email: 'email'
        owner:
            model: 'User'

    afterCreate: (object, cb) ->
        LogService.saveLog 'Create', 'Person', JSON.stringify(object)
        cb()

    afterUpdate: (object, cb) ->
        LogService.saveLog 'Update', 'Person', JSON.stringify(object)
        cb()

    afterDestroy: (object, cb) ->
        LogService.saveLog 'Delete', 'Person', JSON.stringify(object)
        cb()

    beforeCreate: (person, cb) ->
        async.series( [
            (callback) ->
                if person.zip? and person.country? 
                    GeoService.zipGeo person.zip, person.country, (lat, lng) ->
                        person.latitude = lat
                        person.longitude = lng
                        callback null, {lat, lng}
                else
                    callback null
            (callback) ->
                if person.country?
                    GeoService.countryCode person.country, (code) ->
                        person.countryCode = code
                        callback null, code
                else
                    callback null, null
        ], (err, result) ->
            console.log err if err?
            cb null, person
        )

    beforeUpdate: (person, cb) ->
        async.series( [
            (callback) ->
                if person.zip? and person.country? 
                    GeoService.zipGeo person.zip, person.country, (lat, lng) ->
                        person.latitude = lat
                        person.longitude = lng
                        callback null, {lat, lng}
                else
                    callback null
            (callback) ->
                if person.country?
                    GeoService.countryCode person.country, (code) ->
                        person.countryCode = code
                        callback null, code
                else
                    callback null, null
        ], (err, result) ->
            console.log err if err?
            cb null, person
        )
