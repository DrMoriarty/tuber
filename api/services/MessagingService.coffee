module.exports =
    parcelAcceptedByDriver: (requestId) ->
        Request.findOne(requestId).populateAll().exec (err, request) ->
            if err?
                console.log err
            else
                #Message.create({sender: result.driver.id, recipient: result.sender.id, text: 'Carrier accepted your parcel', class: 'parcel', object: result.parcel.id}).exec (err, result) ->
                #    console.log err if err?
                if request.driverAccepted
                    if request.senderAccepted
                        MailingService.processEvent request.driver.email, 'orderAccepted', request.driver.lang, {INFO: ''}
                        shopAddress = if request.fromParcelShopAddress then request.fromParcelShopAddress else ''
                        MailingService.processEvent request.sender.email, 'orderAccepted', request.sender.lang, {INFO: shopAddress}
                    else
                        # TODO

    driverAcceptedByOwner: (requestId) ->
        Request.findOne(requestId).populateAll().exec (err, request) ->
            if err?
                console.log err
            else
                #Message.create({sender: result.sender.id, recipient: result.driver.id, text: 'Sender accepted you', class: 'parcel', object: result.parcel.id}).exec (err, result) ->
                #    console.log err if err?
                if request.senderAccepted
                    if request.driverAccepted
                        MailingService.processEvent request.driver.email, 'orderAccepted', request.driver.lang, {INFO: ''}
                        shopAddress = if request.fromParcelShopAddress then request.fromParcelShopAddress else ''
                        MailingService.processEvent request.sender.email, 'orderAccepted', request.sender.lang, {INFO: shopAddress}
                    else
                        MailingService.processEvent request.driver.email, 'driverNeedAccept', request.driver.lang
                        MailingService.processEvent request.sender.email, 'senderWaitingForAccept', request.sender.lang

    invoicePaid: (requestId) ->
        Request.findOne(requestId).populateAll().exec (err, result) ->
            if err?
                console.log err
            else
                #Message.create({sender: result.driver.id, recipient: result.sender.id, text: 'Parcel has been paid', class: 'parcel', object: result.parcel.id}).exec (err, result) ->
                #    console.log err if err?
                MailingService.processEvent result.sender.email, 'orderPayed', result.sender.lang
    
