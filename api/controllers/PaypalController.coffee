paypal = require 'paypal-rest-sdk'

paypal.configure({
  'mode': 'sandbox', #sandbox or live
  'client_id': 'EBWKjlELKMYqRNQ6sYvFo64FtaRLRR5BdHEESmha49TM',
  'client_secret': 'EO422dn3gQLgDbuwqTjzrFgFtaRLRR5BdHEESmha49TM'
})

module.exports =
    paymentPaypal: (req, res) ->
        payment = {
            "intent": "sale",
            "payer": {
                "payment_method": "paypal"
            },
            "redirect_urls": {
                "return_url": "http://packet24.com/paypal/execute",
                "cancel_url": "http://packet24.com/paypal/cancel"
            },
            "transactions": [{
                "amount": {
                    "total": "5.00",
                    "currency": "USD"
                },
                "description": "My awesome payment"
            }]
        };
        paypal.payment.create payment, (error, payment) ->
            if error?
                console.log(error);
            else
                if payment.payer.payment_method == 'paypal'
                    req.session.paymentId = payment.id;
                    redirectUrl = '/';
                    for link in payment.links
                        if link.method == 'REDIRECT'
                            redirectUrl = link.href;
                    res.redirect(redirectUrl);
        
    paymentCard: (req, res) ->
        payment = {
            "intent": "sale",
            "payer": {
                "payment_method": "credit_card",
                "funding_instruments": [{
                    "credit_card": {
                        "number": "5500005555555559",
                        "type": "mastercard",
                        "expire_month": 12,
                        "expire_year": 2018,
                        "cvv2": 111,
                        "first_name": "Joe",
                        "last_name": "Shopper"
                    }
                }]
            },
            "transactions": [{
                "amount": {
                    "total": "5.00",
                    "currency": "USD"
                },
                "description": "My awesome payment"
            }]
        };  
        paypal.payment.create payment, (error, payment) ->
            if error?
                console.log(error);
            else
                if payment.payer.payment_method == 'paypal'
                    req.session.paymentId = payment.id;
                    redirectUrl = '/';
                    for link in payment.links
                        if link.method == 'REDIRECT'
                            redirectUrl = link.href;
                    res.redirect(redirectUrl);

    execute: (req, res) ->
        paymentId = req.session.paymentId
        payerId = req.param('PayerID')
        details = { "payer_id": payerId }
        paypal.payment.execute paymentId, details, (error, payment) ->
            if error?
                console.log(error);
            else
                res.send("Hell yeah!");

    cancel: (req, res) ->
        res.send("The payment got canceled")

