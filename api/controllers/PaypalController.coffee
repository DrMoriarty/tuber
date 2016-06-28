paypal = require 'paypal-rest-sdk'

paypal.configure({
  'mode': sails.config.tuber.paypal.mode 
  'client_id': sails.config.tuber.paypal.client_id
  'client_secret': sails.config.tuber.paypal.client_secret
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
                            "total": request.totalPrice(),
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
                #res.json(error);
                data = error.response
                data.user = req.user
                if req.mobile
                    res.view 'mpaypalerror', data
                else
                    res.view 'paypalerror', data
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

