module.exports =
    sendEmail: (req, res) ->
        email = req.param('email')
        notificationType = req.param('type')
        if not email or not notificationType
            res.badRequest()
        else
            info = ''
            switch
                when notificationType == 'registrationComplete' then info = ''
                when notificationType == 'passwordRestore' then info = sails.getBaseURL() + '/recovery?hash=0987654321'
                when notificationType == 'passwordGenerated' then info = 'YOURNEWPASSWORD'
                when notificationType == 'orderAccepted' then info = ''
                when notificationType == 'orderPayed' then info = ''
                when notificationType == 'orderPlaced' then info = sails.getBaseURL() + '/upload/349849238479.pdf'
                when notificationType == 'orderArrived' then info = ''
            MailingService.processEvent email, notificationType, 'en', {'INFO': info}
            res.json {status: 'ok'}
