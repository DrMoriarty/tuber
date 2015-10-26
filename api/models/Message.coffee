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

