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
                res.json data

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
