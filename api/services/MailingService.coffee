nodemailer = require 'nodemailer'

module.exports =
    transporter: nodemailer.createTransport
        host: 'smtp.yandex.ru'
        port: 25
        auth:
            user: 'noanswer@apppilgrim.com'
            pass: 'fazedumizu'

    sendEmail: (recipient, subject, text) ->
        MailingService.transporter.sendMail
            from: 'noanswer@apppilgrim.com'
            to: recipient
            subject: subject
            text: text
        console.log 'Email sent to', recipient, subject, text
