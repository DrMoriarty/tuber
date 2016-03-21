paypal = require 'paypal-rest-sdk'

paypal.configure({
  'mode': 'live' #sandbox or live
  #'client_id': 'EBWKjlELKMYqRNQ6sYvFo64FtaRLRR5BdHEESmha49TM'
  #'client_secret': 'EO422dn3gQLgDbuwqTjzrFgFtaRLRR5BdHEESmha49TM'
  ##'client_id': 'AZbqv_U8f3JeJooJJceTSfVbG8XoDaUmuG4kXqx12Tbj8ic_KEv_6DQF3yUNlSPVAmazuVip5LWV-vcF'
  ##'client_secret': 'EJhCwIMnuuFe_BR3XXKWgse5A0g6jr23qk3wUpslxX6DA9Ne6TAKaM_QHiIGpTy-oVvqseT30Kx53xHO'
  'client_id': 'Ab-kxGLHnY1TsnXH5gr_9VkDHTY7aLzbPlN6YsOa7IpT_RyVlPYar3EIQGfG2cmZCyu2EQ1HlphNXJHB'
  'client_secret': 'EGHm9UL-A-phWhY9m-EyRgugGq3zt2gDQMIoNMjbZRiy9HmBMk9LwlyMvIAxl4-OsIiwSY1hop_nWxtM'
})

module.exports =
    paymentPaypal: (req, res) ->
        requestId = req.param('request')
        if requestId?
            Request.findOne(requestId).populateAll().exec (err, request) ->
                if err?
                    console.log err
                    res.negotiate err
                    return
                """
                else if request.paid
                    console.log 'Request already paid', request
                    res.notFound()
                    return
                """
                if req.mobile
                    return_url = "http://m.packet24.com/paypal/execute"
                    cancel_url = "http://m.packet24.com/paypal/cancel"
                else
                    return_url = "http://packet24.com/paypal/execute"
                    cancel_url = "http://packet24.com/paypal/cancel"
                payment = {
                    "intent": "sale",
                    "payer": {
                        "payment_method": "paypal"
                    },
                    "redirect_urls": {
                        "return_url": return_url
                        "cancel_url": cancel_url
                    },
                    "transactions": [{
                        "amount": {
                            "total": request.price,
                            "currency": "EUR"
                        },
                        "description": "Packet24"
                    }]
                };
                paypal.payment.create payment, (error, payment) ->
                    if error?
                        console.log(error);
                    else
                        if payment.payer.payment_method == 'paypal'
                            req.session.paymentId = payment.id
                            req.session.requestId = requestId
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
        requestId = req.session.requestId
        payerId = req.param('PayerID')
        details = { "payer_id": payerId }
        paypal.payment.execute paymentId, details, (error, payment) ->
            if error?
                console.log(error);
                res.json(error);
            else
                console.log 'Paypal payment', payment
                if requestId?
                    Request.update({id: requestId}, {'paid': true, invoice: payment}).exec (err, result) ->
                        if err?
                            console.log err 
                        else
                            MessagingService.invoicePaid requestId
                res.redirect '/dashboard'

    cancel: (req, res) ->
        console.log "The payment got canceled"
        res.redirect '/payment/'+req.session.requestId

