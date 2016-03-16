nodemailer = require 'nodemailer'

module.exports =
    transporter: nodemailer.createTransport
        host: 'smtp2.delti.com'
        port: 25
        auth:
            user: 'svc_packet24'
            pass: 'buC2Mied0r'

    sendEmail: (recipient, subject, text) ->
        options = 
            from: 'info@packet24.com'
            to: recipient
            subject: subject
            text: text
        MailingService.transporter.sendMail options, (err, info) ->
            console.log 'MailingService error', err if err?
            console.log 'Message sent', info.response if info?
        console.log 'Start email sending:', recipient, subject, text
