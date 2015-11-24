
module.exports =
    parcelAcceptedByDriver: (requestId) ->
        Request.findOne(requestId).exec (err, result) ->
            if err?
                console.log err
            else
                Message.create({sender: result.driver, recipient: result.sender, text: 'Carrier accepted your parcel', class: 'parcel', object: result.parcel}).exec (err, result) ->
                    console.log err if err?

    driverAcceptedByOwner: (requestId) ->
        Request.findOne(requestId).exec (err, result) ->
            if err?
                console.log err
            else
                Message.create({sender: result.sender, recipient: result.driver, text: 'Sender accepted you', class: 'parcel', object: result.parcel}).exec (err, result) ->
                    console.log err if err?


    invoicePaid: (requestId) ->
        Request.findOne(requestId).exec (err, result) ->
            if err?
                console.log err
            else
                Message.create({sender: result.driver, recipient: result.sender, text: 'Parcel has been paid', class: 'parcel', object: result.parcel}).exec (err, result) ->
                    console.log err if err?

    
