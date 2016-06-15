async = require 'async'
gps = require 'gps-util'

finishRequest = (senderId, parcelId, driverId, requestId) ->
    Request.destroy({sender: senderId, parcel: parcelId, driver: {'!': driverId}}).exec (err, result) ->
        console.log err if err?
        console.log 'Remove other requests', result
    Parcel.update({id: parcelId}, {status: 'accepted', driver: driverId, request: requestId}).exec (err, result) ->
        console.log err if err?
        console.log 'Update parcel', result

module.exports = 
    searchDriver: (parcelId, cb) ->
        Parcel.findOne(parcelId).populateAll().exec (err, parcel) ->
            if err or not parcel or (parcel.status != 'published' and parcel.status != 'draft')
                console.log err
                cb(err, null)
            else
                searchParams =
                    #country: parcel.owner.country
                    driver: true
                    maxLength: {'>=': parcel.length}
                    maxWidth: {'>=': parcel.width}
                    maxDepth: {'>=': parcel.depth}
                    maxWeight: {'>=': parcel.weight}
                    vehicleNum: {'>': 0}
                User.find(searchParams).populateAll().exec (err, result) ->
                    console.log 'Unfiltered drivers', result
                    drivers = []
                    for driver in result
                        dist = gps.getDistance(parcel.owner.longitude, parcel.owner.latitude, driver.longitude, driver.latitude)
                        if dist*0.001 <= driver.coverageDistance
                            drivers.push driver
                        else
                            console.log 'Too far', dist
                    console.log 'Filtered drivers', drivers
                    cb(null, drivers)
                    
    searchParcel: (driverId, cb) ->
        User.findOne(driverId).populateAll().exec (err, driver) ->
            if err or not driver
                console.log err
                cb(err, null)
            else
                bbox = gps.getBoundingBox(driver.latitude, driver.longitude, driver.coverageDistance*1000)
                console.log 'Bounding box', bbox
                searchParams =
                    longitude: { '>=': bbox[0].lng, '<=': bbox[1].lng}
                    latitude: { '>=': bbox[0].lat, '<=': bbox[1].lat}
                    country: driver.country
                    driver: false
                parcelParams =
                    length: {'<=': driver.maxLength}
                    width: {'<=': driver.maxWidth}
                    depth: {'<=': driver.maxDepth}
                    weight: {'<=': driver.maxWeight}
                console.log 'Search params', searchParams
                User.find(searchParams).exec (err, senders) ->
                    if err or not senders
                        cb(err, null)
                    else
                        console.log 'Unfiltered senders', senders
                        parcels = []
                        async.each senders,
                            (it, callback) ->
                                if gps.getDistance(driver.longitude, driver.latitude, it.longitude, it.latitude)*0.001 > driver.coverageDistance
                                    return callback(null)
                                Parcel.find({owner: it.id, status: 'published'}).where(parcelParams).populateAll().exec (err, result) ->
                                    console.log err if err?
                                    parcels.push.apply(parcels, result)
                                    callback(null)
                            (err) ->
                                if err?
                                    console.log err
                                cb(null, parcels)

    acceptDriver: (driverId, parcelId, cb) ->
        Parcel.findOne(parcelId).populateAll().exec (err, parcel) ->
            if not parcel.owner?
                console.log 'Invalid parcel', parcel, 'No owner!'
                return cb {error: 'No parcel owner'}, null
            Request.find({parcel: parcelId, driver: driverId, sender: parcel.owner.id}).exec (err, requests) ->
                User.findOne(driverId).populateAll().exec (err, driver) ->
                    autoAccept = driver.autoAccept()
                    if err? or not requests or requests.length <= 0
                        newRequest = {parcel: parcelId, driver: driverId, sender: parcel.owner.id, senderAccepted: true}
                        if autoAccept
                            newRequest.driverAccepted = true
                        else
                            now = new Date()
                            newRequest.driverAcceptTimeout = new Date(now);
                            driverAcceptTime = sails.config.tuber.driverAcceptTime || driver.driverAcceptTime
                            newRequest.driverAcceptTimeout.setHours(now.getHours() + driverAcceptTime)
                        Request.create(newRequest).exec (err, result) ->
                            if err?
                                cb err, null
                            else
                                MessagingService.driverAcceptedByOwner result.id
                                if autoAccept
                                    # remove all other requests for this parcel
                                    finishRequest(parcel.owner.id, parcelId, driverId, result.id)
                                cb null, result
                    else
                        request = requests[0]
                        data = {senderAccepted: true}
                        if autoAccept
                            data.driverAccepted = true
                        else
                            now = new Date()
                            data.driverAcceptTimeout = new Date(now);
                            driverAcceptTime = sails.config.tuber.driverAcceptTime || driver.driverAcceptTime
                            data.driverAcceptTimeout.setHours(now.getHours() + driverAcceptTime)
                        Request.update({id: request.id}, data).exec (err, result) ->
                            if err?
                                cb err, null
                            else
                                MessagingService.driverAcceptedByOwner request.id
                                cb null, result
                        if request.driverAccepted or autoAccept
                            # remove all other requests for this parcel
                            finishRequest(parcel.owner.id, parcelId, driverId, request.id)

    acceptParcel: (driverId, parcelId, cb) ->
        Parcel.findOne(parcelId).populateAll().exec (err, parcel) ->
            Request.find({parcel: parcelId, driver: driverId, sender: parcel.owner.id}).populateAll().exec (err, requests) ->
                if err? or not requests or requests.length <= 0
                    Request.create({parcel: parcelId, driver: driverId, sender: parcel.owner.id, driverAccepted: true}).exec (err, result) ->
                        if err?
                            cb err, null
                        else
                            MessagingService.parcelAcceptedByDriver result.id
                            cb null, result
                else
                    request = requests[0]
                    Request.update({id: request.id}, {driverAccepted: true}).exec (err, result) ->
                        if err?
                            cb err, null
                        else
                            MessagingService.parcelAcceptedByDriver request.id
                            cb null, result
                    if request.senderAccepted
                        # we need to remove all other requests from this driver
                        finishRequest(parcel.owner.id, parcelId, driverId, request.id)

    
