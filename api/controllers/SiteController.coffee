 # SiteController
 #
 # @description :: Server-side logic for managing sites
 # @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

moment = require 'moment'
async = require 'async'
gps = require 'gps-util'
fs = require 'fs'
pageSize = 6

module.exports = 
    home: (req, res) ->
        lang = req.getLocale(req)
        moment.locale(lang)
        if req.user?
            if req.user.driver
                if req.mobile
                    res.view 'msitedriver', {user: req.user, lang: lang}
                else
                    res.view 'sitedriver', {user: req.user, lang: lang}
            else
                if req.mobile
                    res.view 'msiteparcel', {user: req.user, lang: lang}
                else
                    res.view 'siteparcel', {user: req.user, lang: lang}
        else
            if req.mobile
                res.view 'msitelogin', {lang: lang}
            else
                res.view 'sitelogin', {lang: lang}

    faq: (req, res) ->
        lang = req.getLocale(req)
        moment.locale(lang)
        if req.mobile
            res.view 'msitefaq', {user: req.user, lang: lang}
        else
            res.view 'sitefaq', {user: req.user, lang: lang}

    registration: (req, res) ->
        lang = req.getLocale(req)
        moment.locale(lang)
        driver = req.param('driver') or false
        if req.mobile
            res.view 'msitereg', {driver: driver, lang: lang}
        else
            res.view 'sitereg', {driver: driver, lang: lang}

    parcel: (req, res) ->
        lang = req.getLocale(req)
        moment.locale(lang)
        if req.user?
            if req.mobile
                res.view 'msiteparcel', {user: req.user, lang: lang}
            else
                res.view 'siteparcel', {user: req.user, lang: lang}
        else
            if req.mobile
                res.redirect '/?m=1'
            else
                res.redirect '/'

    price: (req, res) ->
        lang = req.getLocale(req)
        moment.locale(lang)
        if req.user?
            parcelId = req.param('parcelId')
            Parcel.findOne(parcelId).populateAll().exec (err, parcel) ->
                if err?
                    console.log err
                    return res.negotiate err
                SearchService.searchDriver parcelId, (err, data) ->
                    if err? or not data?
                        console.log err
                        res.negotiate err
                    else
                        SearchService.castingDrivers data, parcel, (carriers, prices) ->
                            if req.mobile
                                res.view 'msiteprice', {user: req.user, parcel: parcel, drivers: prices, more: false, lang: lang}
                            else
                                res.view 'siteprice', {user: req.user, parcel: parcel, drivers: prices, more: false, lang: lang}
        else
            if req.mobile
                res.redirect '/?m=1'
            else
                res.redirect '/'

    dashboard: (req, res) ->
        lang = req.getLocale(req)
        moment.locale(lang)
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
                        res.view view, {user: req.user, parcels: result, archive: archive, payments: [], page: page, pages: Math.ceil(count/pageSize), lang: lang}
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
                    Request.find({paid: true, driver: req.user.id}).sort('createdAt DESC').populateAll().exec (err, requests) ->
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
                                res.view view, {user: req.user, parcels: parcelPage, archive: parcelArchive, payments: payments, page: page, pages: Math.ceil(count/pageSize), lang: lang}
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
                            res.view view, {user: req.user, parcels: result, archive: archive, payments: requests, page: page, pages: Math.ceil(count/pageSize), lang: lang}
            """
        else
            if req.mobile
                res.redirect '/?m=1'
            else
                res.redirect '/'

    confirmation: (req, res) ->
        lang = req.getLocale(req)
        moment.locale(lang)
        if req.user?
            parcelId = req.param('parcelId')
            driverId = req.param('driverId')
            delivery = req.param('delivery')
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
                        (cb) ->
                            SearchService.castingDrivers drivers, parcel, (filteredDrivers, prices) ->
                                drResult = []
                                if prices.cheapest.available
                                    for dr in drivers
                                        if dr.id == prices.cheapest.id
                                            drResult.push {title: req.__('Cheapest delivery'), driver: dr, delivery: 'postbox', price: dr.getPrice(parcel)}
                                            break
                                if prices.fastest.available
                                    for dr in drivers
                                        if dr.id == prices.fastest.id
                                            drResult.push {title: req.__('Fastest delivery'), driver: dr, delivery: 'homeaddress', price: dr.getPrice(parcel)+dr.getDeliveryPrice(parcel)}
                                            break
                                if prices.custom1.available
                                    for dr in drivers
                                        if dr.id == prices.custom1.id
                                            drResult.push {title: dr.fullname(), driver: dr, delivery: 'any', price: dr.getPrice(parcel)}
                                            break
                                if prices.custom2.available
                                    for dr in drivers
                                        if dr.id == prices.custom2.id
                                            drResult.push {title: dr.fullname(), driver: dr, delivery: 'any', price: dr.getPrice(parcel)}
                                            break
                                if prices.custom3.available
                                    for dr in drivers
                                        if dr.id == prices.custom3.id
                                            drResult.push {title: dr.fullname(), driver: dr, delivery: 'any', price: dr.getPrice(parcel)}
                                            break
                                drResult.splice(3)
                                cb null, drResult
                    ], (err, result) ->
                        drResult = result[2]
                        selectedDriver = if drResult? and drResult.length > 0 then drResult[0].driver else null
                        for dr in drResult
                            if dr.driver.id == driverId
                                selectedDriver = dr.driver
                        if req.mobile
                            res.view 'msiteconfirm', {user: req.user, parcel: parcel, drivers: drResult, selected: selectedDriver, fromShops: result[0] or [], toShops: result[1] or [], lang: lang, delivery: delivery}
                        else
                            res.view 'siteconfirm', {user: req.user, parcel: parcel, drivers: drResult, selected: selectedDriver, fromShops: result[0] or [], toShops: result[1] or [], lang: lang, delivery: delivery}
                    )
        else
            if req.mobile
                res.redirect '/?m=1'
            else
                res.redirect '/'

    payment: (req, res) ->
        lang = req.getLocale(req)
        moment.locale(lang)
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
                                res.view 'msitepayment', {user: req.user, parcel: parcel, request: request, driver: driver, token: token, lang: lang}
                            else
                                res.view 'sitepayment', {user: req.user, parcel: parcel, request: request, driver: driver, token: token, lang: lang}
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
        lang = req.getLocale(req)
        moment.locale(lang)
        if req.user?
            if req.mobile
                res.view 'msiteprofile', {user: req.user, lang: lang}
            else
                res.view 'siteprofile', {user: req.user, lang: lang}
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
        lang = req.getLocale(req)
        moment.locale(lang)
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
                Request.update({id: request.id}, {status: 'done'}).exec (err, data) ->
                    console.log err if err?
                shopAddress = request.toParcelShopAddress or ''
                MailingService.processEvent request.sender.email, 'orderArrived', request.sender.lang, {INFO: shopAddress, USERNAME: request.sender.firstname}
            else
                res.notFound()

    restorePassword: (req, res) ->
        lang = req.getLocale(req)
        moment.locale(lang)
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
