braintree = require 'braintree'

module.exports =
    clientToken: (req, res) ->
        uid = req.user._id
        BraintreeService.gateway.clientToken.generate {customerId:uid}, (err, response) ->
            if err?
                console.log err
                res.json {error: err}
            else
                res.json {token: response.clientToken}

    transaction: (req, res) ->
        requestId = req.param('id')
        nonce = req.param('payment_method') or req.param('payment_method_nonce') or 'fake-valid-nonce'
        paymentComplete = (invoice, request) ->
            res.json invoice
            if requestId?
                DepartureService.processRequest requestId
                Request.update({id: requestId}, {'paid': true, invoice: JSON.stringify(invoice)}).exec (err, result) ->
                    if err?
                        console.log err 
                    else
                        MessagingService.invoicePaid requestId
                #Parcel.update({id: request.parcel}, {status: 'accepted', driver: request.driver}).exec (err, result) ->
                #    console.log err if err?
        if not requestId or not nonce
            res.status 400
            res.json {error: 'Bad request'}
        else
            Request.findOne(requestId).exec (err, request) ->
                if err?
                    console.log err
                    res.negotiate err
                else
                    BraintreeService.gateway.transaction.sale { amount: request.price, paymentMethodNonce: nonce}, (err, result) ->
                        if err?
                            console.log err
                            res.status 400
                            res.json {error: err}
                        else if not result.success
                            console.log result
                            res.status 400
                            res.json result
                        else
                            paymentComplete result, request
