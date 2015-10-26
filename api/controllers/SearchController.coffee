module.exports = 
    searchRoute: (req, res) ->
        # TODO
        res.json [
            {
                id: '0000000000000000000'
                owner: {
                    id: '11111111111111111111'
                    firstname: 'Demo'
                    lastname: 'Demo'
                }
                departure: '2015-10-22T19:52:45Z'
                arrival: '2015-10-22T19:52:45Z'
                startAddress:
                    id: '222222222222222222'
                    country: 'Russian Federation'
                    city: 'Moscow'
                    address1: 'Red square'
                    address2: 'b. 1'
                    latitude: '55.7536963'
                    longitude: '37.6198419'
                endAddress:
                    id: '3333333333333333333'
                    country: 'Russian Federation'
                    city: 'Moscow'
                    address1: 'Red square'
                    address2: 'b. 1'
                    latitude: '55.7536963'
                    longitude: '37.6198419'
            }
        ]

    searchParcel: (req, res) ->
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
