 # SiteController
 #
 # @description :: Server-side logic for managing sites
 # @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

moment = require 'moment'
async = require 'async'
gps = require 'gps-util'
fs = require 'fs'
pageSize = 3

module.exports = 
    home: (req, res) ->
        if req.user?
            if req.user.driver
                if req.mobile
                    res.view 'msitedriver', {user: req.user, lang: req.getLocale(req)}
                else
                    res.view 'sitedriver', {user: req.user, lang: req.getLocale(req)}
            else
                if req.mobile
                    res.view 'msiteparcel', {user: req.user, lang: req.getLocale(req)}
                else
                    res.view 'siteparcel', {user: req.user, lang: req.getLocale(req)}
        else
            if req.mobile
                res.view 'msitelogin', {lang: req.getLocale(req)}
            else
                res.view 'sitelogin', {lang: req.getLocale(req)}

    faq: (req, res) ->
        if req.mobile
            res.view 'msitefaq', {user: req.user, lang: req.getLocale(req)}
        else
            res.view 'sitefaq', {user: req.user, lang: req.getLocale(req)}

    registration: (req, res) ->
        driver = req.param('driver') or false
        if req.mobile
            res.view 'msitereg', {driver: driver, lang: req.getLocale(req)}
        else
            res.view 'sitereg', {driver: driver, lang: req.getLocale(req)}

    parcel: (req, res) ->
        if req.user?
            if req.mobile
                res.view 'msiteparcel', {user: req.user, lang: req.getLocale(req)}
            else
                res.view 'siteparcel', {user: req.user, lang: req.getLocale(req)}
        else
            if req.mobile
                res.redirect '/?m=1'
            else
                res.redirect '/'

    price: (req, res) ->
        if req.user?
            parcelId = req.param('parcelId')
            Parcel.findOne(parcelId).populateAll().exec (err, parcel) ->
                if err?
                    console.log err
                    return res.negotiate err
                SearchService.searchDriver parcelId, (err, data) ->
                    if err?
                        console.log err
                        res.negotiate err
                    else
                        prices =
                            cheapest: 
                                price: ''
                                pickupDate: '-'
                                arriveDate: '-'
                                available: false
                            fastest:
                                price: ''
                                pickupDate: '-'
                                arriveDate: '-'
                                available: false
                            ecologiest:
                                price: ''
                                pickupDate: '-'
                                arriveDate: '-'
                                available: false
                        console.log 'Drivers', data
                        cheapest = fastest = ecologiest = null
                        pathLength = parcel.pathLength
                        for carrier in data
                            if cheapest?
                                if carrier.getPrice(parcel) < cheapest.getPrice(parcel)
                                    cheapest = carrier
                            else
                                cheapest = carrier
                            if fastest?
                                if carrier.averageDayDistance > fastest.averageDayDistance or (carrier.averageDayDistance == fastest.averageDayDistance and carrier.averageSpeed > fastest.averageSpeed)
                                    fastest = carrier
                            else
                                fastest = carrier
                            if ecologiest?
                                if carrier.averageSpeed < ecologiest.averageSpeed
                                    ecologiest = carrier
                            else
                                ecologiest = carrier
                        if cheapest?
                            prices.cheapest.id = cheapest.id
                            prices.cheapest.price = cheapest.getPrice parcel
                            prices.cheapest.available = true
                        if fastest?
                            prices.fastest.id = fastest.id
                            prices.fastest.price = fastest.getPrice parcel
                            prices.fastest.available = true
                        if ecologiest?
                            prices.ecologiest.id = ecologiest.id
                            prices.ecologiest.price = ecologiest.getPrice parcel
                            prices.ecologiest.available = true
                        console.log 'Prices', prices
                        moreAvailable = data.length > 3
                        if req.mobile
                            res.view 'msiteprice', {user: req.user, parcel: parcel, drivers: prices, more: moreAvailable, lang: req.getLocale(req)}
                        else
                            res.view 'siteprice', {user: req.user, parcel: parcel, drivers: prices, more: moreAvailable, lang: req.getLocale(req)}
        else
            if req.mobile
                res.redirect '/?m=1'
            else
                res.redirect '/'

    dashboard: (req, res) ->
        page = req.param('page') or 1
        if req.user? and not req.user.driver
            filter = {owner: req.user.id, status: {'!': ['archive', 'canceled']}}
            Parcel.count(filter).exec (err, count) ->
                Parcel.find(filter).sort('createdAt DESC').paginate({page:page, limit:pageSize}).populateAll().exec (err, result) ->
                    if err
                        console.log err
                        return res.negotiate err
                    Parcel.find({owner: req.user.id, status: ['archive', 'canceled']}).populateAll().exec (err, archive) ->
                        if err
                            console.log err
                            return res.negotiate err
                        if req.mobile
                            view = 'msitedashboard'
                        else
                            view = 'sitedashboard'
                        res.view view, {user: req.user, parcels: result, archive: archive, payments: [], page: page, pages: Math.floor(count/pageSize)+1, lang: req.getLocale(req)}
        else if req.user? and req.user.driver
            async.series( [
                (cb) ->
                    Request.find({driver: req.user.id}).sort('createdAt DESC').populateAll().exec (err, requests) ->
                        result = []
                        archive = []
                        for request in requests
                            if request.parcel?
                                if request.parcel.status not in ['arrived', 'archive', 'canceled']
                                    result.push request
                                else
                                    archive.push request
                        cb(err, [result, archive])
                (cb) ->
                    Request.find({paid: true}).sort('createdAt DESC').populateAll().exec (err, requests) ->
                        console.log 'Get completed requests', requests
                        cb(err, requests)
            ], (err, result) ->
                if err
                    console.log err
                    return res.negotiate err
                r1 = result[0]
                requests = r1[0]
                count = requests.length
                archive = r1[1]
                payments = result[1]
                if req.mobile
                    view = 'msitedriverdashboard'
                else
                    view = 'sitedriverdashboard'
                async.map archive,
                    (it, cb) ->
                        Parcel.findOne(it.parcel.id).populateAll().exec (err, parcel) ->
                            cb err, parcel
                    (err, parcelArchive) ->
                        pageContent = requests.splice((page-1)*pageSize, pageSize)
                        async.map pageContent,
                            (it, cb) ->
                                Parcel.findOne(it.parcel.id).populateAll().exec (err, parcel) ->
                                    cb err, parcel
                            (err, parcelPage) ->
                                res.view view, {user: req.user, parcels: parcelPage, archive: parcelArchive, payments: payments, page: page, pages: Math.floor(count/pageSize)+1, lang: req.getLocale(req)}
            )
            """
            filter = {driver: req.user.id, status: {'!': ['arrived', 'archive', 'canceled']}}
            Parcel.count(filter).exec (err, count) ->
                Parcel.find(filter).sort('createdAt DESC').paginate({page:page, limit:pageSize}).populateAll().exec (err, result) ->
                    if err
                        console.log err
                        return res.negotiate err
                    Parcel.find({driver: req.user.id, status: ['arrived', 'archive', 'canceled']}).populateAll().exec (err, archive) ->
                        if err
                            console.log err
                            return res.negotiate err
                        if req.mobile
                            view = 'msitedriverdashboard'
                        else
                            view = 'sitedriverdashboard'
                        Request.find({paid: true}).sort('createdAt DESC').populateAll().exec (err, requests) ->
                            console.log 'Get completed requests', requests
                            res.view view, {user: req.user, parcels: result, archive: archive, payments: requests, page: page, pages: Math.floor(count/pageSize)+1, lang: req.getLocale(req)}
            """
        else
            if req.mobile
                res.redirect '/?m=1'
            else
                res.redirect '/'

    confirmation: (req, res) ->
        if req.user?
            parcelId = req.param('parcelId')
            driverId = req.param('driverId')
            Parcel.findOne(parcelId).populateAll().exec (err, parcel) ->
                if err?
                    console.log err
                    return res.negotiate err
                SearchService.searchDriver parcelId, (err, drivers) ->
                    if err?
                        console.log err
                        return res.negotiate err
                    fromAddress = if parcel.fromPerson? then parcel.fromPerson else parcel.owner
                    toAddress = if parcel.toPerson? then parcel.toPerson else parcel.owner
                    async.series( [
                        (cb) ->
                            DpdService.findParcelShopsByGeoData fromAddress.latitude, fromAddress.longitude, (err, data) ->
                                if err?
                                    console.log err 
                                    return cb(err, null)
                                try
                                    fromParcelShops = data["soap:Envelope"]["soap:Body"][0]["ns:findParcelShopsByGeoDataResponse"][0]["parcelShop"]
                                    return cb(null, fromParcelShops)
                                catch e
                                    console.log 'Parcel shops for ', fromAddress.latitude, fromAddress.longitude, ' not found!'
                                    return cb(null, [])
                        (cb) ->
                            DpdService.findParcelShopsByGeoData toAddress.latitude, toAddress.longitude, (err, data) ->
                                if err?
                                    console.log err
                                    return cb(err, null)
                                try 
                                    toParcelShops = data["soap:Envelope"]["soap:Body"][0]["ns:findParcelShopsByGeoDataResponse"][0]["parcelShop"]
                                    return cb(null, toParcelShops)
                                catch e
                                    console.log 'Parcel shops for ', toAddress.latitude, toAddress.longitude, ' not found!'
                                    return cb(null, [])
                    ], (err, result) ->
                        if req.mobile
                            res.view 'msiteconfirm', {user: req.user, parcel: parcel, drivers: drivers, selected: driverId, fromShops: result[0] or [], toShops: result[1] or [], lang: req.getLocale(req)}
                        else
                            res.view 'siteconfirm', {user: req.user, parcel: parcel, drivers: drivers, selected: driverId, fromShops: result[0] or [], toShops: result[1] or [], lang: req.getLocale(req)}
                    )
        else
            if req.mobile
                res.redirect '/?m=1'
            else
                res.redirect '/'

    payment: (req, res) ->
        if req.user?
            requestId = req.param('requestId')
            Request.findOne(requestId).populateAll().exec (err, request) ->
                if err?
                    console.log err
                    return res.negotiate err
                if not request?
                    return res.notFound()
                Parcel.findOne(request.parcel.id).populateAll().exec (err, parcel) ->
                    if err?
                        console.log err
                        return res.negotiate err
                    User.findOne(request.driver.id).populateAll().exec (err, driver) ->
                        if err?
                            console.log err
                            return res.negotiate err
                        BraintreeService.clientToken req.user.id, (token, err) ->
                            console.log err if err?
                            if req.mobile
                                res.view 'msitepayment', {user: req.user, parcel: parcel, request: request, driver: driver, token: token, lang: req.getLocale(req)}
                            else
                                res.view 'sitepayment', {user: req.user, parcel: parcel, request: request, driver: driver, token: token, lang: req.getLocale(req)}
        else
            if req.mobile
                res.redirect '/?m=1'
            else
                res.redirect '/'

    findPayment: (req, res) ->
        parcelId = req.param('parcel')
        if parcelId
            Request.find({parcel: parcelId, senderAccepted: true}).exec (err, requests) ->
                if err?
                    console.log err
                    return res.negotiate err
                if requests? and requests.length > 0
                    if req.mobile
                        res.redirect '/payment/'+requests[0].id+'?m=1'
                    else
                        res.redirect '/payment/'+requests[0].id
        else
            if req.mobile
                res.redirect '/?m=1'
            else
                res.redirect '/'

    profile: (req, res) ->
        if req.user?
            if req.mobile?
                res.view 'msiteprofile', {user: req.user, lang: req.getLocale(req)}
            else
                res.view 'siteprofile', {user: req.user, lang: req.getLocale(req)}
        else
            if req.mobile
                res.redirect '/?m=1'
            else
                res.redirect '/'

    makeParcel: (req, res) ->
        data = req.body
        console.log 'Parcel 1', data
        parcel = {owner: req.user.id, length: data.length, width: data.width, depth: data.depth, weight: data.weight}
        if data.pickupDate?.length > 0
            parcel.pickupDate = moment(data.pickupDate, 'DD MMMM YYYY').format()
        if data.arriveDate?.length > 0
            parcel.arriveDate = moment(data.arriveDate, 'DD MMMM YYYY').format()
        if data.pickupTime1?.length > 0
            parcel.pickupTime1 = data.pickupTime1
        if data.pickupTime2?.length > 0
            parcel.pickupTime2 = data.pickupTime2
        if data.arriveTime1?.length > 0
            parcel.arriveTime1 = data.arriveTime1
        if data.arriveTime2?.length > 0
            parcel.arriveTime2 = data.arriveTime2
        if data.insurance?
            parcel.insurance = data.insurance
        console.log 'Parsed parcel', parcel
        if data.fromPersonProfile and data.toPersonProfile
            console.log 'Incorrect addresses (both set to profile address)'
            return res.badRequest {error: 'Incorrect addresses (both set to profile address)'}
        fromPerson = {firstname: data['fromPerson.firstName'], lastname: data['fromPerson.lastName'], phone: data['fromPerson.phone'], country: data['fromPerson.country'], city: data['fromPerson.city'], address1: data['fromPerson.address1'], address2: data['fromPerson.address2'], zip: data['fromPerson.zip'], owner: req.user.id}
        toPerson = {firstname: data['toPerson.firstName'], lastname: data['toPerson.lastName'], phone: data['toPerson.phone'], country: data['toPerson.country'], city: data['toPerson.city'], address1: data['toPerson.address1'], address2: data['toPerson.address2'], zip: data['toPerson.zip'], owner: req.user.id}
        async.series( [
            (cb) ->
                if data.fromPersonProfile
                    return cb(null, null)
                else
                    GeoService.zipGeo fromPerson.zip, fromPerson.country, (lat, lng) ->
                        if not lat? or not lng?
                            return cb('From address error', null)
                        fromPerson.latitude = lat
                        fromPerson.longitude = lng
                        Person.create(fromPerson).exec (err, address) ->
                            if err?
                                console.log err
                                return cb(err, null)
                            else
                                return cb(null, address.id)
            (cb) ->
                if data.toPersonProfile
                    return cb(null, null)
                else
                    GeoService.zipGeo toPerson.zip, toPerson.country, (lat, lng) ->
                        if not lat? or not lng?
                            return cb('To address error', null)
                        toPerson.latitude = lat
                        toPerson.longitude = lng
                        Person.create(toPerson).exec (err, address) ->
                            if err?
                                console.log err
                                return cb(err, null)
                            else
                                return cb(null, address.id)
        ], (err, result) ->
            if err?
                console.log err
                return res.negotiate err
            if not data.fromPersonProfile
                parcel.fromPerson = result[0]
            if not data.toPersonProfile
                parcel.toPerson = result[1]
            Parcel.create(parcel).exec (err, result) ->
                if err?
                    console.log err
                    res.negotiate err
                else
                    res.json {status: 'ok', parcel: result.id}
        )

    subscript: (req, res) ->
        if not req.user?
            if req.mobile
                return res.redirect '/?m=1'
            else
                return res.redirect '/'
        parcelId = req.param('parcel')
        Parcel.findOne(parcelId).populateAll().exec (err, parcel) ->
            console.log err if err?
            if req.mobile
                res.render 'msitescript', {user: req.user, parcel: parcel}
            else
                res.render 'sitescript', {user: req.user, parcel: parcel}

    makeSubscript: (req, res) ->
        if not req.user?
            res.badRequest()
        parcelId = req.param('parcel')
        if not parcelId?
            return res.badRequest 'parcel required'
        pngFile = req.param('subscript')
        if not pngFile? or pngFile.length < 22
            return res.badRequest('subscript required')
        Request.find({parcel: parcelId, senderAccepted: true}).populateAll().exec (err, requests) ->
            if err?
                console.log err
                return res.negotiate err
            if requests? and requests.length > 0
                request = requests[0]
                pngFile = pngFile.substring(22)
                fileContent = new Buffer(pngFile, 'base64')
                fs.writeFile 'upload/subscript_'+request.id+'.png', fileContent, (err) ->
                    console.log err if err?
                Parcel.update({id: parcelId}, {status: 'arrived'}).exec (err, data) ->
                    if err?
                        console.log err
                        res.negotiate err
                    else
                        res.json {status: 'success'}
                MailingService.processEvent request.sender.email, 'orderArrived', request.sender.lang
            else
                res.notFound()

    restorePassword: (req, res) ->
        if req.mobile
            res.render 'msiterecovery', {}
        else
            res.render 'siterecovery', {}
        
    setLanguage: (req, res) ->
        lang = req.param('lang')
        l = lang
        if lang == 'en' or lang == 'English'
            l = 'en'
        else if lang == 'de' or lang == 'Deutch'
            l = 'de'
        req.session.lang = l
        console.log 'Set language', l
        res.cookie('language', l)
        res.json {language: l, status: 'ok'}
