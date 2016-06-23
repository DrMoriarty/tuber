async = require 'async'

"""
finishRequest = (senderId, parcelId, driverId) ->
    Request.destroy({sender: senderId, parcel: parcelId, driver: {'!': driverId}}).exec (err, result) ->
        console.log err if err?
        console.log 'Remove other requests', result
    Parcel.update({id: parcelId}, {status: 'accepted', driver: driverId}).exec (err, result) ->
        console.log err if err?
        console.log 'Update parcel', result
"""

module.exports = 
    searchDriver: (req, res) ->
        parcelId = req.param('parcel')
        console.log 'Parcel', parcelId
        SearchService.searchDriver parcelId, (err, result) ->
            if err or not result
                res.notFound()
            else
                res.json result
                    
    searchParcel: (req, res) ->
        driverId = req.param('driver')
        console.log 'Driver', driverId
        SearchService.searchParcel driverId, (err, result) ->
            if err or not result
                res.notFound()
            else
                res.json result

    searchParcelInEllipse: (req, res) ->
        # TODO
        res.json [
            {
                owner: {
                    id: '000000000000'
                    firstname: 'Demo'
                    lastname: 'Demo'
                }
                driver: {
                    id: '111111111111'
                    firstname: 'Demo'
                    lastname: 'Demo'
                }
                fromPerson: {
                    id: '222222222222'
                    firstname: 'Demo'
                    lastname: 'Demo'
                }
                toPerson: {
                    id: '333333333333'
                    firstname: 'Demo'
                    lastname: 'Demo'
                }
                length: 100
                width: 100
                depth: 100
                weight: 50
                comment: ''
                pickupDate: '2015-10-22T19:52:45Z'
                arrivedDate: '2015-10-22T19:52:45Z'
                status: 'published'
            }
        ]

    messages: (req, res) ->
        since = req.param('since')
        params =
            sort: 'createdAt DESC'
        if since?
            params.createdAt = {'>': since}
        Message.find(params).exec (err, result) ->
            if err?
                console.log err
                return res.negotiate err
            res.json result
            
    acceptDriver: (req, res) ->
        driverId = req.param('driverId')
        parcelId = req.param('parcelId')
        SearchService.acceptDriver driverId, parcelId, (err, result) ->
            if err?
                res.json err
            else
                res.json result
        """
        Parcel.findOne(parcelId).populateAll().exec (err, parcel) ->
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
                                res.json err
                            else
                                MessagingService.driverAcceptedByOwner result.id
                                res.json result
                        if autoAccept
                            # remove all other requests for this parcel
                            finishRequest(parcel.owner.id, parcelId, driverId)
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
                                res.json err
                            else
                                MessagingService.driverAcceptedByOwner request.id
                                res.json result
                        if request.driverAccepted or autoAccept
                            # remove all other requests for this parcel
                            finishRequest(parcel.owner.id, parcelId, driverId)
        """

    acceptParcel: (req, res) ->
        driverId = req.user.id
        parcelId = req.param('parcelId')
        SearchService.acceptParcel driverId, parcelId, (err, result) ->
            if err?
                res.json err
            else
                res.json result
        """
        Parcel.findOne(parcelId).populateAll().exec (err, parcel) ->
            Request.find({parcel: parcelId, driver: driverId, sender: parcel.owner.id}).populateAll().exec (err, requests) ->
                if err? or not requests or requests.length <= 0
                    Request.create({parcel: parcelId, driver: driverId, sender: parcel.owner.id, driverAccepted: true}).exec (err, result) ->
                        if err?
                            res.json err
                        else
                            MessagingService.parcelAcceptedByDriver result.id
                            res.json result
                else
                    request = requests[0]
                    Request.update({id: request.id}, {driverAccepted: true}).exec (err, result) ->
                        if err?
                            res.json err
                        else
                            MessagingService.parcelAcceptedByDriver request.id
                            res.json result
                    if request.senderAccepted
                        # we need to remove all other requests from this driver
                        finishRequest(parcel.owner.id, parcelId, driverId)
        """

    lookupZip: (req, res) ->
        zip = req.param('zip')
        country = req.param('country')
        if not zip? 
            return res.badRequest('zip required')
        if not country?
            return res.badRequest('country required')
        Zip.find({code: zip}).populateAll().exec (err, result) ->
            for zcode in result
                if zcode.latitude? and zcode.latitude != 0 and zcode.longitude? and zcode.longitude != 0
                    return res.json {latitude: zcode.latitude, longitude: zcode.longitude}
            GeoService.zipGeo zip, country, (lat, lng) ->
                if lat? and lng?
                    res.json {latitude: lat, longitude: lng}
                else
                    res.json {error: 'Address not found'}
