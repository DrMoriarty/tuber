nodemailer = require 'nodemailer'

module.exports =
    transporter: nodemailer.createTransport
        host: 'smtp2.delti.com'
        port: 25
        auth:
            user: 'svc_packet24'
            pass: ''

    sendEmail: (recipient, subject, text) ->
        MailingService.transporter.sendMail
            from: 'info@packet24.com'
            to: recipient
            subject: subject
            text: text
        console.log 'Email sent to', recipient, subject, text
