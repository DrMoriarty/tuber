geocoder = require 'geocoder'
query_overpass = require 'query-overpass'
util = require 'util'

module.exports = 
    zipGeoFromGoogle: (zip, country, callback) ->
        # reverse geocoding by zip (using google maps)
        address = zip
        if country?
            address = address + ', ' + country
        geocoder.geocode address, (err, data) ->
            console.log err if err?
            latitude = undefined
            longitude = undefined
            if not err and data
                if data.results? and data.results.length > 0
                    res = data.results[0]
                    if res.geometry?.location?
                        latitude = res.geometry.location.lat
                        longitude = res.geometry.location.lng
            callback latitude, longitude
    
    zipGeoFromOSM: (zip, country, callback, strict=true) ->
        # reverse geocoding by zip (using openstreetmap overpass)
        if strict
            request = '[out:json];area[postal_code="'+zip+'"]->.a;(node(area.a)["addr:postcode"][amenity=post_office];);out 1;'
        else
            request = '[out:json];area[postal_code="'+zip+'"]->.a;(node(area.a)["addr:postcode"];);out 1;'
        query_overpass request, (err, data) ->
            console.log err if err?
            latitude = undefined
            longitude = undefined
            console.log 'Overpass data', util.inspect(data, {showHidden: false, depth: null})
            if not err and data and data.features?.length > 0
                feature = data.features[0]
                if feature.geometry?.type == 'Point'
                    longitude = feature.geometry.coordinates[0]
                    latitude = feature.geometry.coordinates[1]
            else if strict
                # no data, try to call non strict request
                GeoService.zipGeoFromOSM zip, country, callback, false
            else
                callback latitude, longitude

    zipGeo: (zip, country, callback) ->
        found = false
        count = 0
        GeoService.zipGeoFromOSM zip, country, (lat, lng) ->
            count += 1
            if not found and lat? and lng?
                found = true
                return callback lat, lng
            if not found and count == 2
                # both methods founded nothing
                callback 0, 0
        GeoService.zipGeoFromGoogle zip, country, (lat, lng) ->
            count += 1
            if not found and lat? and lng?
                found = true
                return callback lat, lng
            if not found and count == 2
                # both methods founded nothing
                callback 0, 0
