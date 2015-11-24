"""
 Route.js

 @description :: TODO: You might write a short summary of how this model works and what it represents here.
 @docs        :: http://sailsjs.org/#!documentation/models
"""

module.exports = 
  attributes: 
    owner:
        model: 'User'
        required: true
    departure:
        type: 'datetime'
        required: true
    arrival:
        type: 'datetime'
        required: true
    startAddress:
        model: 'Address'
        required: true
    endAddress:
        model: 'Address'
        required: true

    afterCreate: (object, cb) ->
        LogService.saveLog 'Create', 'Route', JSON.stringify(object)
        cb()

    afterUpdate: (object, cb) ->
        LogService.saveLog 'Update', 'Route', JSON.stringify(object)
        cb()

    afterDestroy: (object, cb) ->
        LogService.saveLog 'Delete', 'Route', JSON.stringify(object)
        cb()

