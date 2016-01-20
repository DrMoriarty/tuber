braintree = require 'braintree'

gateway = braintree.connect
    environment: braintree.Environment.Sandbox,
    merchantId: "vs3nz3h3jzk5b42m",
    publicKey: "kkhysrr54nrv2z3z",
    privateKey: "9e95960119e025f7c1cade114eefb3b4"

module.exports =
    clientToken: (req, res) ->
        uid = req.user._id
        gateway.clientToken.generate {customerId:uid}, (err, response) ->
            if err?
                console.log err
                res.json {error: err}
            else
                res.json {token: response.clientToken}

    transaction: (req, res) ->
        requestId = req.param('id')
        nonce = req.param('payment_method') or req.param('payment_method_nonce') or 'fake-valid-nonce'
        if not requestId or not nonce
            res.status 400
            res.json {error: 'Bad request'}
        else
            Request.findOne(requestId).exec (err, request) ->
                if err?
                    console.log err
                    res.negotiate err
                else
                    gateway.transaction.sale { amount: request.price, paymentMethodNonce: nonce}, (err, result) ->
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
                                DepartureService.processRequest requestId
                                Request.update({id: requestId}, {'paid': true, invoice: JSON.stringify(result)}).exec (err, result) ->
                                    if err?
                                        console.log err 
                                    else
                                        MessagingService.invoicePaid requestId
                                Parcel.update({id: request.parcel}, {status: 'accepted', driver: request.driver}).exec (err, result) ->
                                    console.log err if err?
