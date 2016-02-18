fs = require 'fs'

module.exports =
    getAuth: (req, res) ->
        DpdService.getAuth (err, data) ->
            if err?
                #res.setHeader( "Content-type", "text/xml" )
                res.json err
            else
                res.json data

    storeOrders: (req, res) ->
        parcelId = req.param('parcel')
        DpdService.storeOrders parcelId, (err, data) ->
            if err?
                #res.setHeader( "Content-type", "text/xml" )
                res.json err
            else
                #res.json data
                result = data['soap:Envelope']['soap:Body'][0]['ns2:storeOrdersResponse'][0].orderResult[0]
                fileContent = new Buffer(result.parcellabelsPDF[0], 'base64')
                fs.writeFile 'upload/'+parcelId+'.pdf', fileContent, (err) ->
                    console.log err if err?
                shipmentData =
                    type: 'DPD'
                    identificationNumber: result.shipmentResponses[0].identificationNumber[0]
                    mpsId: result.shipmentResponses[0].mpsId[0]
                    parcelLabelNumber: result.shipmentResponses[0].parcelInformation[0].parcelLabelNumber[0]
                Parcel.update({id: parcelId}, {shipment: shipmentData}).exec (err, result) ->
                    if err?
                        res.negotiate(err)
                    else
                        res.json result

    getTrackingData: (req, res) ->
        labelNumber = req.param('labelnumber')
        DpdService.getTrackingData labelNumber, (err, data) ->
            if err?
                #res.setHeader( "Content-type", "text/xml" )
                res.json err
            else
                res.json data

    getParcelLabelNumber: (req, res) ->
        DpdService.getParcelLabelNumber (err, data) ->
            if err?
                #res.setHeader( "Content-type", "text/xml" )
                res.json err
            else
                res.json data

    findParcelShops: (req, res) ->
        DpdService.findParcelShops (err, data) ->
            if err?
                #res.setHeader( "Content-type", "text/xml" )
                res.json err
            else
                res.json data

    findParcelShopsByGeoData: (req, res) ->
        lat = req.param('latitude')
        lng = req.param('longitude')
        if not lat or not lng
            return res.badRequest()
        DpdService.findParcelShopsByGeoData lat, lng, (err, data) ->
            if err?
                #res.setHeader( "Content-type", "text/xml" )
                res.json err
            else
                #res.setHeader( "Content-type", "text/xml" )
                res.json data

    findCities: (req, res) ->
        DpdService.findCities (err, data) ->
            if err?
                #res.setHeader( "Content-type", "text/xml" )
                res.json err
            else
                res.json data

    getAvailableServices: (req, res) ->
        DpdService.getAvailableServices (err, data) ->
            if err?
                #res.setHeader( "Content-type", "text/xml" )
                res.json err
            else
                res.json data
