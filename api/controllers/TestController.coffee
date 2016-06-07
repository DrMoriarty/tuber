module.exports =
    sendEmail: (req, res) ->
        email = req.param('email')
        notificationType = req.param('type')
        if not email or not notificationType
            res.badRequest()
        else
            TestService.sendEmail email, notificationType, 'en'
            res.json {status: 'ok'}
