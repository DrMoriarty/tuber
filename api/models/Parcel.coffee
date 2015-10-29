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
        fromPerson: 
            model: 'Person'
        toPerson:
            model: 'Person'
        length: 
            type: 'number'
            defaultsTo: 0
        width:
            type: 'number'
            defaultsTo: 0
        depth:
            type: 'number'
            defaultsTo: 0
        weight:
            type: 'number'
            defaultsTo: 0
        comment: 'string'
        pickupDate: 
            type: 'datetime'
            required: true
        arriveDate: 
            type: 'datetime'
            required: true
        status: 
            type: 'string'
            enum: ['draft', 'published', 'accepted', 'started', 'arrived']


