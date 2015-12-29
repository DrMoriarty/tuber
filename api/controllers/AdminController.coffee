async = require 'async'
pageSize = 20

finishRequest = (senderId, parcelId, driverId) ->
    Request.destroy({sender: senderId, parcel: parcelId, driver: {'!': driverId}}).exec (err, result) ->
        console.log err if err?
        console.log 'Remove other requests', result
    Parcel.update({id: parcelId}, {status: 'accepted', driver: driverId}).exec (err, result) ->
        console.log err if err?
        console.log 'Update parcel', result

module.exports =
    main: (req, res) ->
        res.view 'blank', {user: req.user}

    profile: (req, res) ->
        res.view 'profile', {user: req.user}

    profileEdit: (req, res) ->
        res.view 'profileEdit', {user: req.user}

    countries: (req, res) ->
        res.view 'countries', {user: req.user}

    cities: (req, res) ->
        res.view 'cities', {user: req.user}

    parcel: (req, res) ->
        id = req.param('id')
        Parcel.findOne(id).populateAll().exec (err, result) ->
            console.log result
            if err or !result
                res.notFound()
            else
                res.view 'parcel', {user: req.user, result: result}
        
    parcels: (req, res) ->
        page = req.param('page') or 1
        sort = req.param('sort') or 'createdAt'
        Parcel.count().exec (err, count) ->
            Parcel.find().sort(sort).paginate({page:page, limit:pageSize}).populateAll().exec (err, result) ->
                res.view 'parcels', {user: req.user, result: result, sort: sort, page: page, pages: (count/pageSize)+1}

    newParcel: (req, res) ->
        User.find({driver: false}).exec (err, senders) ->
            Person.find().exec (err, persons) ->
                res.view 'newParcel', {user: req.user, senders: senders, persons: persons}
        
    person: (req, res) ->
        id = req.param('id')
        Person.findOne(id).exec (err, result) ->
            if err or !result
                res.notFound()
            else
                res.view 'person', {user: req.user, result: result}

    persons: (req, res) ->
        page = req.param('page') or 1
        sort = req.param('sort') or 'createdAt'
        Person.count().exec (err, count) ->
            Person.find().sort(sort).paginate({page:page, limit:pageSize}).populateAll().exec (err, result) ->
                res.view 'persons', {user: req.user, result: result, sort: sort, page: page, pages: (count/pageSize)+1}

    newPerson: (req, res) ->
        res.view 'newperson', {user: req.user}

    route: (req, res) ->
        id = req.param('id')
        Route.findOne(id).exec (err, result) ->
            if err or !result
                res.notFound()
            else
                res.view 'route', {user: req.user, result: result}

    routes: (req, res) ->
        res.view 'routes', {user: req.user}

    carrier: (req, res) ->
        id = req.param('id')
        User.findOne(id).exec (err, result) ->
            if err or !result
                res.notFound()
            else
                res.view 'carrier', {user: req.user, result: result}

    carriers: (req, res) ->
        page = req.param('page') or 1
        sort = req.param('sort') or 'createdAt'
        filter = {driver: true, admin: false}
        User.count(filter).exec (err, count) ->
            User.find(filter).sort(sort).paginate({page:page, limit:pageSize}).exec (err, result) ->
                res.view 'carriers', {user: req.user, result: result, sort: sort, page: page, pages: (count/pageSize)+1}

    newCarrier: (req, res) ->
        res.view 'newcarrier', {user: req.user}

    sender: (req, res) ->
        id = req.param('id')
        User.findOne(id).exec (err, result) ->
            if err or !result
                res.notFound()
            else
                res.view 'sender', {user: req.user, result: result}

    senders: (req, res) ->
        page = req.param('page') or 1
        sort = req.param('sort') or 'createdAt'
        filter = {driver: false, admin: false}
        User.count(filter).exec (err, count) ->
            User.find(filter).sort(sort).paginate({page:page, limit:pageSize}).exec (err, result) ->
                res.view 'senders', {user: req.user, result: result, sort: sort, page: page, pages: (count/pageSize)+1}

    newSender: (req, res) ->
        res.view 'newsender', {user: req.user}

    search: (req, res) ->
        # TODO
        res.view 'search', {user: req.user}

    findCarriers: (req, res) ->
        parcelId = req.param('id')
        SearchService.searchDriver parcelId, (err, result) ->
            drivers = []
            async.each result,
                (it, cb) ->
                    Request.find({parcel: parcelId, driver: it.id}).populateAll().exec (err, res) ->
                        if res? and res.length > 0
                            it.request = res[0]
                        drivers.push(it)
                        cb(null)
                (err) ->
                    console.log err if err?
                    console.log 'Found drivers', drivers
                    res.view 'findcarriers', {user: req.user, parcelId: parcelId, result: drivers, err: err}

    findParcels: (req, res) ->
        driverId = req.param('id')
        SearchService.searchParcel driverId, (err, result) ->
            parcels = []
            async.each result,
                (it, cb) ->
                    Request.find({parcel: it.id, driver: driverId}).populateAll().exec (err, res) ->
                        if res? and res.length > 0
                            it.request = res[0]
                        parcels.push(it)
                        cb(null)
                (err) ->
                    console.log err if err?
                    console.log 'Found parcels', parcels
                    res.view 'findparcels', {user: req.user, driverId: driverId, result: parcels, err: err}

    acceptDriver: (req, res) ->
        driverId = req.param('driverId')
        parcelId = req.param('parcelId')
        Parcel.findOne(parcelId).populateAll().exec (err, parcel) ->
            Request.find({parcel: parcelId, driver: driverId, sender: parcel.owner.id}).exec (err, requests) ->
                if err? or not requests or requests.length <= 0
                    Request.create({parcel: parcelId, driver: driverId, sender: parcel.owner.id, senderAccepted: true}).exec (err, result) ->
                        if err?
                            res.json err
                        else if req.wantsJSON
                            MessagingService.driverAcceptedByOwner result.id
                            res.json result
                        else
                            MessagingService.driverAcceptedByOwner result.id
                            res.redirect '/admin/request'
                else
                    driverAccepted = false
                    for req in requests
                        if req.driverAccepted
                            driverAccepted = true
                    Request.update({parcel: parcelId, driver: driverId, sender: parcel.owner.id}, {senderAccepted: true}).exec (err, result) ->
                        if err?
                            res.json err
                        else if req.wantsJSON
                            MessagingService.driverAcceptedByOwner result.id
                            res.json result
                        else
                            MessagingService.driverAcceptedByOwner result.id
                            res.redirect '/admin/request'
                    if driverAccepted
                        # remove all other requests for this parcel
                        finishRequest(parcel.owner.id, parcelId, driverId)

    acceptParcel: (req, res) ->
        driverId = req.param('driverId')
        parcelId = req.param('parcelId')
        Parcel.findOne(parcelId).populateAll().exec (err, parcel) ->
            Request.find({parcel: parcelId, driver: driverId, sender: parcel.owner.id}).populateAll().exec (err, requests) ->
                if err? or not requests or requests.length <= 0
                    Request.create({parcel: parcelId, driver: driverId, sender: parcel.owner.id, driverAccepted: true}).exec (err, result) ->
                        if err?
                            res.json err
                        else if req.wantsJSON
                            MessagingService.parcelAcceptedByDriver result.id
                            res.json result
                        else
                            MessagingService.parcelAcceptedByDriver result.id
                            res.redirect '/admin/request'
                else
                    senderAccepted = false
                    for req in requests
                        if req.senderAccepted
                            senderAccepted = true
                    Request.update({parcel: parcelId, driver: driverId, sender: parcel.owner.id}, {driverAccepted: true}).exec (err, result) ->
                        if err?
                            res.json err
                        else if req.wantsJSON
                            MessagingService.parcelAcceptedByDriver result.id
                            res.json result
                        else
                            MessagingService.parcelAcceptedByDriver result.id
                            res.redirect '/admin/request'
                    if senderAccepted
                        # we need to remove all other requests from this driver
                        finishRequest(parcel.owner.id, parcelId, driverId)

    requests: (req, res) ->
        page = req.param('page') or 1
        sort = req.param('sort') or 'createdAt'
        Request.count().exec (err, count) ->
            Request.find().sort(sort).paginate({page:page, limit:pageSize}).populateAll().exec (err, result) ->
                res.view 'requests', {user: req.user, result: result, sort: sort, page: page, pages: (count/pageSize)+1}

    serverTests: (req, res) ->
        res.view 'pressureTest', {user: req.user}

    stressTest: (req, res) ->
        count = req.param('count') or 10
        step = count / 10
        complex = []
        c = step
        for i in [0...10]
            complex.push {list: TestService.defaultTestList, count: c}
            c += step
        TestService.performComplexTest complex, (result) ->
            res.json result
            console.log result

    logs: (req, res) ->
        LogService.lastLogs 25, (err, result) ->
            res.view 'logs', {user: req.user, result: result}
