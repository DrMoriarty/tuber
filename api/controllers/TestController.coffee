module.exports =
    sendEmail: (req, res) ->
        email = req.param('email')
        notificationType = req.param('type')
        lang = req.param('language') or 'en'
        if not email or not notificationType
            res.badRequest()
        else
            TestService.sendEmail email, notificationType, lang
            res.json {status: 'ok'}
