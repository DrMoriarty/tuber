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
