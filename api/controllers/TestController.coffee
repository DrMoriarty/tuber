module.exports =
    sendEmail: (req, res) ->
        email = req.param('email')
        notificationType = req.param('type')
        if not email or not notificationType
            res.badRequest()
        else
            MailingService.processEvent email, notificationType, 'en', null
            res.json {status: 'ok'}
