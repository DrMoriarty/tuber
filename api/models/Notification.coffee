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
            enum: ['registrationComplete', 'registrationCompleteCarrier', 'passwordRestore', 'passwordGenerated', 'driverNeedAccept', 'senderWaitingForAccept', 'orderAccepted', 'orderPayed', 'orderPlaced', 'orderArrived']
            required: true
        subject: 'string'
        text: 'string'
