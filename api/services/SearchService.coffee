async = require 'async'
gps = require 'gps-util'
module.exports = 
    searchDriver: (parcelId, cb) ->
        Parcel.findOne(parcelId).populateAll().exec (err, parcel) ->
            if err or not parcel or parcel.status != 'published'
                console.log err
                cb(err, null)
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

