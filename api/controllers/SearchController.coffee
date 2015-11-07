async = require 'async'
gps = require 'gps-util'

module.exports = 
    searchDriver: (req, res) ->
        parcelId = req.param('parcel') or '563c6686d96d0fb479187263'
        SearchService.searchDriver parcelId, (err, result) ->
            if err or not result
                res.notFound()
            else
                res.json result
        """
        Parcel.findOne(parcelId).populateAll().exec (err, parcel) ->
            if err or not parcel or parcel.status != 'published'
                console.log err
                res.notFound()
            else
                searchParams =
                    country: parcel.owner.country
                    driver: true
                    maxLength: {'>=': parcel.length}
                    maxWidth: {'>=': parcel.width}
                    maxDepth: {'>=': parcel.depth}
                    maxWeight: {'>=': parcel.weight}
                    vehicleNum: {'>': 0}
                User.find(searchParams).populateAll().exec (err, result) ->
                    drivers = []
                    for driver in result
                        if gps.getDistance(parcel.owner.longitude, parcel.owner.latitude, driver.longitude, driver.latitude,) <= driver.coverageDistance
                            drivers.push driver
                    res.json drivers
        """
                    
    searchParcel: (req, res) ->
        driverId = req.param('driver') or '563a5e6302c9c80a38e3a015'
        SearchService.searchParcel driverId, (err, result) ->
            if err or not result
                res.notFound()
            else
                res.json result
        """
        User.findOne(driverId).populateAll().exec (err, driver) ->
            if err or not driver
                console.log err
                res.notFound()
            else
                bbox = gps.getBoundingBox(driver.latitude, driver.longitude, driver.coverageDistance)
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
                User.find(searchParams).exec (err, senders) ->
                    if err or not senders
                        res.notFound()
                    else
                        parcels = []
                        async.eachSeries senders,
                            (it, cb) ->
                                if gps.getDistance(driver.longitude, driver.latitude, it.longitude, it.latitude) > driver.coverageDistance
                                    return cb(null)
                                Parcel.find({owner: it.id, status: 'published'}).where(parcelParams).populateAll().exec (err, result) ->
                                    console.log err if err?
                                    parcels.push.apply(parcels, result)
                                    cb(null)
                            (err) ->
                                if err?
                                    console.log err
                                res.json parcels
        """

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
        # TODO
        res.json [
            {
                sender: null
                recipient: {
                    id: '0000000000'
                    firstname: 'Demo'
                    lastname: 'Demo'
                }
                text: 'Demo message'
                class: 'parcel'
                object: '111111111111'
            }
            {
                sender: null
                recipient: {
                    id: '0000000000'
                    firstname: 'Demo'
                    lastname: 'Demo'
                }
                text: 'Demo message'
                class: 'parcel'
                object: '111111111111'
            }
        ]
