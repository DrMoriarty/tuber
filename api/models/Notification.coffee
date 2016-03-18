 # Notifications.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models

module.exports =
    attributes:
        lang:
            type: 'string'
            required: true
        event:
            type: 'string'
            enum: ['registrationComplete', 'passwordRestore', 'passwordGenerated', 'orderAccepted', 'orderPayed', 'orderArrived']
            required: true
        subject: 'string'
        text: 'string'
