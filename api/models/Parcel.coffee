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
        arriveDate: 
            type: 'datetime'
        status: 
            type: 'string'
            enum: ['draft', 'published', 'accepted', 'started', 'arrived']


