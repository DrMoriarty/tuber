"""
 Person.js

 @description :: TODO: You might write a short summary of how this model works and what it represents here.
 @docs        :: http://sailsjs.org/#!documentation/models
"""

module.exports = 
    attributes:
        firstname: 
            type: 'string'
            required: true
        lastname: 
            type: 'string'
            required: true
        address1: 
            type: 'string'
            required: true
        address2:
            type: 'string'
            required: true
        zip: 'string'
        city:
            type: 'string'
            required: true
        country:
            type: 'string'
            required: true
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
