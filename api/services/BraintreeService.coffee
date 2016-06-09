braintree = require 'braintree'

"""
    gateway: braintree.connect
        environment:  braintree.Environment.Production,
        merchantId:   '6y2m8cxqccs373b8',
        publicKey:    '96dwxqd8tppggct6',
        privateKey:   '2c38014ddf08d4a2849be745c6e96a41'

    gateway: braintree.connect
        environment: braintree.Environment.Sandbox
        merchantId: 'vs3nz3h3jzk5b42m'
        publicKey: 'kkhysrr54nrv2z3z'
        privateKey: '9e95960119e025f7c1cade114eefb3b4'
"""

module.exports =
    gateway: braintree.connect(sails.config.tuber.braintree)

    clientToken: (uid, cb) ->
        BraintreeService.gateway.clientToken.generate {}, (err, response) ->
            if err?
                console.log 'Braintree token error', err
                cb null, err
            else
                cb response.clientToken, null

    transaction: (req, res) ->
        nonce = req.body.payment_method or req.body.payment_method_nonce or 'fake-valid-nonce'
        amount = req.body.amount or 1.0
        requestId = req.body.request_id
        if not requestId or not amount or not nonce
            res.status 400
            res.json {error: 'Bad request'}
        else
            BraintreeService.gateway.transaction.sale { amount: amount, paymentMethodNonce: nonce}, (err, result) ->
                if err?
                    console.log err
                    res.status 400
                    res.json {error: err}
                else if not result.success
                    console.log result
                    res.status 400
                    res.json result
                else
                    res.json result
                    if requestId?
                        Request.update({id: requestId}, {'paid': true, invoice: result}).exec (err, result) ->
                            if err?
                                console.log err 
                            else
                                MessagingService.invoicePaid requestId
