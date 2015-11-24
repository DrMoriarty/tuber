"""
 Message.js

 @description :: TODO: You might write a short summary of how this model works and what it represents here.
 @docs        :: http://sailsjs.org/#!documentation/models
"""

module.exports = 
  attributes: 
    sender:
        model: 'User'
    recipient:
        model: 'User'
        required: true
    text: 'string'
    class: 'string'
    object: 'string'
    read:
        type: 'boolean'
        defaultsTo: false

    afterCreate: (object, cb) ->
        LogService.saveLog 'Create', 'Message', JSON.stringify(object)
        cb()

    afterUpdate: (object, cb) ->
        LogService.saveLog 'Update', 'Message', JSON.stringify(object)
        cb()

    afterDestroy: (object, cb) ->
        LogService.saveLog 'Delete', 'Message', JSON.stringify(object)
        cb()
