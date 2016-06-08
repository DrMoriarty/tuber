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
        deliveryOption:
            type: 'string'
            defaultsTo: ''
        deliveryPrice:
            type: 'float'
            defaultsTo: 0
        trackingNumber:
            type: 'string'
        status:
            type: 'string'
        fromParcelShop:
            type: 'string'
        toParcelShop:
            type: 'string'
        driverAcceptTimeout:
            type: 'datetime'

        totalPrice: ->
            return ((if @price? then @price else 0) + (if @deliveryPrice? then @deliveryPrice else 0) + (if @parcel.insurance? then @parcel.insurance else 0)).toFixed(2)

    afterCreate: (object, cb) ->
        LogService.saveLog 'Create', 'Request', JSON.stringify(object)
        cb()

    afterUpdate: (object, cb) ->
        LogService.saveLog 'Update', 'Request', JSON.stringify(object)
        cb()

    afterDestroy: (object, cb) ->
        LogService.saveLog 'Delete', 'Request', JSON.stringify(object)
        cb()

