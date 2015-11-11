async = require 'async'

module.exports = 
    searchDriver: (req, res) ->
        parcelId = req.param('parcel')
        SearchService.searchDriver parcelId, (err, result) ->
            if err or not result
                res.notFound()
            else
                res.json result
                    
    searchParcel: (req, res) ->
        driverId = req.param('driver')
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
