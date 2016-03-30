
module.exports =
    parcelAcceptedByDriver: (requestId) ->
        Request.findOne(requestId).populateAll().exec (err, result) ->
            if err?
                console.log err
            else
                Message.create({sender: result.driver.id, recipient: result.sender.id, text: 'Carrier accepted your parcel', class: 'parcel', object: result.parcel.id}).exec (err, result) ->
                    console.log err if err?
                MailingService.processEvent result.sender.email, 'orderAccepted', result.sender.lang

    driverAcceptedByOwner: (requestId) ->
        Request.findOne(requestId).populateAll().exec (err, result) ->
            if err?
                console.log err
            else
                Message.create({sender: result.sender.id, recipient: result.driver.id, text: 'Sender accepted you', class: 'parcel', object: result.parcel.id}).exec (err, result) ->
                    console.log err if err?
                MailingService.processEvent result.driver.email, 'orderAccepted', result.driver.lang


    invoicePaid: (requestId) ->
        Request.findOne(requestId).populateAll().exec (err, result) ->
            if err?
                console.log err
            else
                Message.create({sender: result.driver.id, recipient: result.sender.id, text: 'Parcel has been paid', class: 'parcel', object: result.parcel.id}).exec (err, result) ->
                    console.log err if err?
                MailingService.processEvent result.sender.email, 'orderPayed', result.sender.lang
    
