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
