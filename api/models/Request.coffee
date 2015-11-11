"""
 Request.js

 @description :: TODO: You might write a short summary of how this model works and what it represents here.
 @docs        :: http://sailsjs.org/#!documentation/models
"""

module.exports = 
    attributes:
        parcel:
            model: 'Parcel'
            required: true
        driver:
            model: 'User'
            required: true
        sender:
            model: 'User'
            required: true
        driverAccepted:
            type: 'boolean'
            defaultsTo: false
        senderAccepted:
            type: 'boolean'
            defaultsTo: false
        invoice: 'string'
        price:
            type: 'float'
            defaultsTo: 0
        paid:
            type: 'boolean'
            defaultsTo: false


