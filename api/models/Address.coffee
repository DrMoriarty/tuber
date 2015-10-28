"""
 Address.js

 @description :: TODO: You might write a short summary of how this model works and what it represents here.
 @docs        :: http://sailsjs.org/#!documentation/models
"""

module.exports = 
  attributes: 
    country: 
        type: 'string'
        required: true
    city:
        type: 'string'
        required: true
    address1:
        type: 'string'
        required: false
    address2:
        type: 'string'
        required: false
    latitude:
        type: 'float'
        defaultsTo: 0
    longitude:
        type: 'float'
        defaultsTo: 0
