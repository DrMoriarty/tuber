"""
 RoutePoint.js

 @description :: TODO: You might write a short summary of how this model works and what it represents here.
 @docs        :: http://sailsjs.org/#!documentation/models
"""

module.exports = 
    attributes: 
        address:
            model: 'Address'
            required: true
        route:
            model: 'Route'
            required: true
        date:
            type: 'datetime'
        owner:
            model: 'User'

    afterCreate: (object, cb) ->
        LogService.saveLog 'Create', 'RoutePoint', JSON.stringify(object)
        cb()

    afterUpdate: (object, cb) ->
        LogService.saveLog 'Update', 'RoutePoint', JSON.stringify(object)
        cb()

    afterDestroy: (object, cb) ->
        LogService.saveLog 'Delete', 'RoutePoint', JSON.stringify(object)
        cb()

