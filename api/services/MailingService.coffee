nodemailer = require 'nodemailer'

module.exports =
    transporter: nodemailer.createTransport
        host: sails.config.tuber.mailing.host
        port: sails.config.tuber.mailing.port
        #secure: true
        auth:
            user: sails.config.tuber.mailing.user
            pass: sails.config.tuber.mailing.pass

    sendEmail: (recipient, subject, text) ->
        options = 
            from: 'info@packet24.com'
            to: recipient
            subject: subject
            html: text
        MailingService.transporter.sendMail options, (err, info) ->
            console.log 'MailingService error', err if err?
            console.log 'Message sent', info.response if info?
        console.log 'Start email sending:', recipient, subject, text

    processEvent: (recipient, eventType, lang, additionalText) ->
        if not recipient?
            console.log 'Can not send ', eventType, 'to nobody!'
            return
        if not lang?
            lang = 'en'
        Notification.find({lang:lang, event: eventType}).exec (err, result) ->
            if err or !result
                console.log 'Event text not found!', lang, eventType
            else if result.length > 0
                nt = result[0]
                text = nt.text
                if additionalText?
                    if typeof additionalText is 'string'
                        text += additionalText
                    else
                        for own key, value of additionalText
                            text = text.replace key, value
                MailingService.sendEmail recipient, nt.subject, text
