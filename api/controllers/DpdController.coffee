module.exports =
    getAuth: (req, res) ->
        DpdService.getAuth (err, data) ->
            #res.setHeader( "Content-type", "text/xml" )
            res.send data

    storeOrders: (req, res) ->
        DpdService.storeOrders (err, data) ->
            #res.setHeader( "Content-type", "text/xml" )
            res.send data

    getTrackingData: (req, res) ->
        DpdService.getTrackingData (err, data) ->
            #res.setHeader( "Content-type", "text/xml" )
            res.send data

    getParcelLabelNumber: (req, res) ->
        DpdService.getParcelLabelNumber (err, data) ->
            #res.setHeader( "Content-type", "text/xml" )
            res.send data
