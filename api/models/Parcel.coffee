"""
 Parcel.js

 @description :: TODO: You might write a short summary of how this model works and what it represents here.
 @docs        :: http://sailsjs.org/#!documentation/models
"""

module.exports = 
    attributes:
        owner: 
            model: 'User'
            required: true
        driver:
            model: 'User'
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
        pickupTime1: 'string'
        pickupTime2: 'string'
        arriveDate: 
            type: 'datetime'
        arriveTime1: 'string'
        arriveTime2: 'string'
        insurance:
            type: 'float'
            defaultsTo: 0
        status: 
            type: 'string'
            enum: ['draft', 'published', 'accepted', 'started', 'arrived']

    afterCreate: (object, cb) ->
        LogService.saveLog 'Create', 'Parcel', JSON.stringify(object)
        cb()

    afterUpdate: (object, cb) ->
        LogService.saveLog 'Update', 'Parcel', JSON.stringify(object)
        cb()

    afterDestroy: (object, cb) ->
        LogService.saveLog 'Delete', 'Parcel', JSON.stringify(object)
        cb()

