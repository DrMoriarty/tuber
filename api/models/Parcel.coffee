"""
 Parcel.js

 @description :: TODO: You might write a short summary of how this model works and what it represents here.
 @docs        :: http://sailsjs.org/#!documentation/models
"""

async = require 'async'
gps = require 'gps-util'

module.exports = 
    attributes:
        owner: 
            model: 'User'
            required: true
        driver:
            model: 'User'
            defaultsTo: null
        request:
            model: 'Request'
            defaultsTo: null
        fromPerson: 
            model: 'Person'
        toPerson:
            model: 'Person'
        length: 
            type: 'integer'
            defaultsTo: 0
        width:
            type: 'integer'
            defaultsTo: 0
        depth:
            type: 'integer'
            defaultsTo: 0
        weight:
            type: 'integer'
            defaultsTo: 0
        comment: 'string'
        pickupDate: 
            type: 'datetime'
            required: true
        pickupTime1:
            type: 'string'
            defaultsTo: '09:00'
        pickupTime2:
            type: 'string'
            defaultsTo: '18:00'
        arriveDate: 
            type: 'datetime'
        arriveTime1:
            type: 'string'
            defaultsTo: '09:00'
        arriveTime2:
            type: 'string'
            defaultsTo: '18:00'
        insurance:
            type: 'float'
            defaultsTo: 0
        insurancePrice:
            type: 'float'
        pathLength:
            type: 'float'
        status: 
            type: 'string'
            enum: ['draft', 'published', 'accepted', 'started', 'arrived', 'archive']
            defaultsTo: 'draft'

        ownerAddress: ->
            @owner.zip + ' ' + @owner.city + ' ' + @owner.address1 + ' ' + @owner.address2
        fromPersonAddress: ->
            (if @fromPerson.zip? then @fromPerson.zip else '') + ' ' + @fromPerson.city + ' ' + @fromPerson.address1 + ' ' + @fromPerson.address2
        toPersonAddress: ->
            (if @toPerson.zip? then @toPerson.zip else '') + ' ' + @toPerson.city + ' ' + @toPerson.address1 + ' ' + @toPerson.address2

    beforeCreate: (parcel, cb) ->
        if parcel.insurance? and parcel.insurance > 0
            # TODO calc insurance !!!
            parcel.insurancePrice = 10
        cb()

    afterCreate: (parcel, cb) ->
        LogService.saveLog 'Create', 'Parcel', JSON.stringify(parcel)
        cb()
        async.series( [
            (cb) ->
                User.findOne(parcel.owner).exec (err, user) ->
                    console.log err if err?
                    cb err, user
            (cb) ->
                if parcel.fromPerson?
                    Person.findOne(parcel.fromPerson).exec (err, person) ->
                        console.log err if err?
                        cb err, person
                else
                    cb null, null
            (cb) ->
                if parcel.toPerson?
                    Person.findOne(parcel.toPerson).exec (err, person) ->
                        console.log err if err?
                        cb err, person
                else
                    cb null, null
        ], (err, result) ->
            if result[1]?
                startPoint = [result[1].longitude, result[1].latitude]
            else
                startPoint = [result[0].longitude, result[0].latitude]
            if result[2]?
                endPoint = [result[2].longitude, result[2].latitude]
            else
                endPoint = [result[0].longitude, result[0].latitude]
            pathLength = gps.getDistance(startPoint[0], startPoint[1], endPoint[0], endPoint[1])
            if pathLength != parcel.pathLength
                Parcel.update({id: parcel.id}, {pathLength: pathLength}).exec (err, result) ->
                    console.log err if err?
        )

    beforeUpdate: (parcel, cb) ->
        if parcel.insurance? and parcel.insurance > 0
            # TODO calc insurance !!!
            parcel.insurancePrice = 10
        cb()

    afterUpdate: (parcel, cb) ->
        LogService.saveLog 'Update', 'Parcel', JSON.stringify(parcel)
        console.log 'Parcel', parcel
        cb()
        async.series( [
            (cb) ->
                User.findOne(parcel.owner).exec (err, user) ->
                    console.log err if err?
                    cb err, user
            (cb) ->
                if parcel.fromPerson?
                    Person.findOne(parcel.fromPerson).exec (err, person) ->
                        console.log err if err?
                        cb err, person
                else
                    cb null, null
            (cb) ->
                if parcel.toPerson?
                    Person.findOne(parcel.toPerson).exec (err, person) ->
                        console.log err if err?
                        cb err, person
                else
                    cb null, null
        ], (err, result) ->
            if result[1]?
                startPoint = [result[1].longitude, result[1].latitude]
            else
                startPoint = [result[0].longitude, result[0].latitude]
            if result[2]?
                endPoint = [result[2].longitude, result[2].latitude]
            else
                endPoint = [result[0].longitude, result[0].latitude]
            pathLength = gps.getDistance(startPoint[0], startPoint[1], endPoint[0], endPoint[1])
            if pathLength != parcel.pathLength
                Parcel.update({id: parcel.id}, {pathLength: pathLength}).exec (err, result) ->
                    console.log err if err?
        )

    afterDestroy: (object, cb) ->
        LogService.saveLog 'Delete', 'Parcel', JSON.stringify(object)
        cb()

