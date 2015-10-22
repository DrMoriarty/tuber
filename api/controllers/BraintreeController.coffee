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
        nonce = if req.body?.payment_method? then req.body.payment_method else 'fake-valid-nonce'
        amount = if req.body?.amount? then req.body.amount else 1.0
        gateway.transaction.sale { amount: amount, paymentMethodNonce: nonce}, (err, result) ->
            if err?
                console.log err
                res.json {error: err}
            else
                res.json result
