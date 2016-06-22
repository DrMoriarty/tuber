async = require 'async'
moment = require 'moment'
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

    parcelLog: (req, res) ->
        id = req.param('id')
        Parcel.findOne(id).populateAll().exec (err, parcel) ->
            if err or !parcel
                res.notFound()
            else
                senderId = if parcel.fromPerson then parcel.fromPerson.id else parcel.owner
                acceptorId = if parcel.toPerson then parcel.toPerson.id else parcel.owner
                async.series( [
                    (cb) ->
                        LogService.logsForObject 10, id, (err, logs) ->
                            return cb(err, logs)
                    (cb) ->
                        LogService.logsForObject 10, senderId, (err, senderLogs) ->
                            return cb(err, senderLogs)
                    (cb) ->
                        LogService.logsForObject 10, acceptorId, (err, acceptorLogs) ->
                            return cb(err, acceptorLogs)
                    (cb) ->
                        Request.find({parcel: id, driverAccepted: true, senderAccepted: true}).populateAll().exec (err, requests) ->
                            if err or not requests or requests.length <= 0
                                console.log err
                                return cb(err, [])
                            else
                                LogService.logsForObject 10, requests[0].id, (err, requestLogs) ->
                                    return cb(err, requestLogs)
                ], (err, result) ->
                    res.view 'parcellog', {user: req.user, parcel: parcel, logs: result[0], senderLogs: result[1], acceptorLogs: result[2], requestLogs: result[3]}
                )

    parcelFinance: (req, res) ->
        id = req.param('id')
        Request.find({parcel: id, senderAccepted: true}).populateAll().exec (err, requests) ->
            if err or not requests or requests.length <= 0
                console.log err
                res.view 'parcelfinance', {user: req.user}
            else
                request = requests[0]
                if request.invoice and request.invoice.length > 0
                    invoice = JSON.parse(request.invoice)
                    delete request.invoice
                else
                    invoice = null
                res.view 'parcelfinance', {user: req.user, request: request, invoice: invoice}

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
        sort = req.param('sort') or 'createdAt DESC'
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
        sort = req.param('sort') or 'createdAt DESC'
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
        sort = req.param('sort') or 'createdAt DESC'
        filter = {driver: true, admin: false}
        search = req.param('search')
        if search? and search.length > 0
            filter['$text'] = {$search: search}
            User.native (err, collection) ->
                collection.find(filter).toArray (err, result) ->
                    for r in result
                        r.id = r._id
                        delete r._id
                        delete r.password
                    res.view 'carriers', {user: req.user, result: result, sort: null, page: 1, pages: 1}
        else
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
        sort = req.param('sort') or 'createdAt DESC'
        filter = {driver: false, admin: false}
        search = req.param('search')
        if search? and search.length > 0
            filter['$text'] = {$search: search}
            User.native (err, collection) ->
                collection.find(filter).toArray (err, result) ->
                    for r in result
                        r.id = r._id
                        delete r._id
                        delete r.password
                    res.view 'senders', {user: req.user, result: result, sort: null, page: 1, pages: 1}
        else
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
        Parcel.find({driver: driverId}).exec (err, result) ->
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
        """
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
        """

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
        sort = req.param('sort') or 'createdAt DESC'
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

    payments: (req, res) ->
        page = req.param('page') or 1
        sort = req.param('sort') or 'createdAt DESC'
        fromDate = req.param('fromDate')
        toDate = req.param('toDate')
        enableDone = if req.param('enableDone')? then JSON.parse(req.param('enableDone')) else true
        enableDoing = if req.param('enableDoing')? then JSON.parse(req.param('enableDoing')) else true
        filter = {}
        if fromDate? and toDate?
            filter.createdAt = {'>=': fromDate, '<=': toDate}
        else if fromDate?
            filter.createdAt = {'>=': fromDate}
        else if toDate?
            filter.createdAt = {'<=': toDate}
        if not enableDoing and not enableDone
            return res.view 'payments', {user: req.user, result: [], sort: sort, page: 0, pages: 1, fromDate: fromDate, toDate: toDate, enableDoing: enableDoing, enableDone: enableDone}
        else if enableDone and not enableDoing
            filter.status = 'done';
        else if enableDoing and not enableDone
            filter.status = {$ne: 'done'};
        Request.count(filter).exec (err, count) ->
            Request.find(filter).sort(sort).paginate({page:page, limit:pageSize}).populateAll().exec (err, requests) ->
                async.each requests,
                    (it, cb) ->
                        if it.parcel?
                            Parcel.findOne({id: it.parcel.id}).populateAll().exec (err, parcel) ->
                                if parcel?
                                    it.parcel = parcel
                                cb(null)
                        else
                            cb(null)
                    (err) ->
                        res.view 'payments', {user: req.user, result: requests, sort: sort, page: page, pages: (count/pageSize)+1, fromDate: fromDate, toDate: toDate, enableDoing: enableDoing, enableDone: enableDone}

    paymentsFile: (req, res) ->
        fromDate = req.param('fromDate')
        toDate = req.param('toDate')
        enableDone = if req.param('enableDone')? then JSON.parse(req.param('enableDone')) else true
        enableDoing = if req.param('enableDoing')? then JSON.parse(req.param('enableDoing')) else true
        filter = {}
        if fromDate? and toDate?
            filter.createdAt = {'>=': fromDate, '<=': toDate}
        else if fromDate?
            filter.createdAt = {'>=': fromDate}
        else if toDate?
            filter.createdAt = {'<=': toDate}
        s = 'Carrier;Sender;Receiver;Arrive Date;Paid;Competed;Sum;\n'
        if not enableDoing and not enableDone
            res.attachment('report.csv')
            res.send new Buffer(s)
            return
        else if enableDone and not enableDoing
            filter.status = 'done';
        else if enableDoing and not enableDone
            filter.status = {$ne: 'done'};
        Request.find(filter).populateAll().exec (err, result) ->
            for r in result
                from = if r.parcel? and r.parcel.fromPerson? then r.parcel.fromPerson else r.sender
                to = if r.parcel? and r.parcel.toPerson? then r.parcel.toPerson else r.sender
                arrivedate = if r.parcel? then moment(r.parcel.arriveDate).format('LL') else ''
                drName = if r.driver? then r.driver.firstname + ' ' + r.driver.lastname else ''
                frName = if from? then from.firstname + ' ' + from.lastname else ''
                toName = if to? then to.firstname + ' ' + to.lastname else ''
                s = s +
                """
                #{drName};#{frName};#{toName};#{arrivedate};#{r.paid};#{r.status};#{r.price}\n
                """
            console.log 'Filter', filter
            res.attachment('report.csv')
            res.send new Buffer(s)

    notifications: (req, res) ->
        page = req.param('page') or 1
        sort = req.param('sort') or 'createdAt DESC'
        Notification.count().exec (err, count) ->
            Notification.find().sort(sort).paginate({page:page, limit:pageSize}).populateAll().exec (err, result) ->
                res.view 'notifications', {user: req.user, result: result, sort: sort, page: page, pages: (count/pageSize)+1}

    newNotification: (req, res) ->
        res.view 'newNotification', {user: req.user}

    notification: (req, res) ->
        id = req.param('id')
        Notification.findOne(id).exec (err, result) ->
            if err or !result
                res.notFound()
            else
                res.view 'notification', {user: req.user, result: result}
