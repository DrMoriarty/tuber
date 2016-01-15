 # SiteController
 #
 # @description :: Server-side logic for managing sites
 # @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

moment = require 'moment'
async = require 'async'
gps = require 'gps-util'
pageSize = 3

module.exports = 
    home: (req, res) ->
        mobile = req.param('mobile') or req.param('m') or false
        if req.user?
            if req.user.driver
                if mobile
                    res.view 'msitedriver', {user: req.user}
                else
                    res.view 'sitedriver', {user: req.user}
            else
                if mobile
                    res.view 'msiteparcel', {user: req.user}
                else
                    res.view 'siteparcel', {user: req.user}
        else
            if mobile
                res.view 'msitelogin'
            else
                res.view 'sitelogin'

    faq: (req, res) ->
        mobile = req.param('mobile') or req.param('m') or false
        if mobile
            res.view 'msitefaq'
        else
            res.view 'sitefaq'

    registration: (req, res) ->
        mobile = req.param('mobile') or req.param('m') or false
        driver = req.param('driver') or false
        if mobile
            res.view 'msitereg', {driver: driver}
        else
            res.view 'sitereg', {driver: driver}

    parcel: (req, res) ->
        mobile = req.param('mobile') or req.param('m') or false
        if req.user?
            if mobile
                res.view 'msiteparcel', {user: req.user}
            else
                res.view 'siteparcel', {user: req.user}
        else
            if mobile
                res.redirect '/?m=1'
            else
                res.redirect '/'

    price: (req, res) ->
        mobile = req.param('mobile') or req.param('m') or false
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
                                if carrier.getPrice(pathLength) < cheapest.getPrice(pathLength)
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
                            prices.cheapest.price = cheapest.getPrice pathLength
                            prices.cheapest.available = true
                        if fastest?
                            prices.fastest.id = fastest.id
                            prices.fastest.price = fastest.getPrice pathLength
                            prices.fastest.available = true
                        if ecologiest?
                            prices.ecologiest.id = ecologiest.id
                            prices.ecologiest.price = ecologiest.getPrice pathLength
                            prices.ecologiest.available = true
                        console.log 'Prices', prices
                        moreAvailable = data.length > 3
                        if mobile
                            res.view 'msiteprice', {user: req.user, parcel: parcel, drivers: prices, more: moreAvailable}
                        else
                            res.view 'siteprice', {user: req.user, parcel: parcel, drivers: prices, more: moreAvailable}
        else
            if mobile
                res.redirect '/?m=1'
            else
                res.redirect '/'

    dashboard: (req, res) ->
        mobile = req.param('mobile') or req.param('m') or false
        page = req.param('page') or 1
        if req.user?
            filter = {owner: req.user.id, status: {'!': 'archive'}}
            Parcel.count(filter).exec (err, count) ->
                Parcel.find(filter).paginate({page:page, limit:pageSize}).populateAll().exec (err, result) ->
                    if err
                        console.log err
                        return res.negotiate err
                    Parcel.find({owner: req.user.id, status: 'archive'}).populateAll().exec (err, archive) ->
                        if err
                            console.log err
                            return res.negotiate err
                        if mobile
                            res.view 'msitedashboard', {user: req.user, parcels: result, archive: archive, payments: [], page: page, pages: Math.floor(count/pageSize)+1}
                        else
                            res.view 'sitedashboard', {user: req.user, parcels: result, archive: archive, payments: [], page: page, pages: Math.floor(count/pageSize)+1}
        else
            if mobile
                res.redirect '/?m=1'
            else
                res.redirect '/'

    confirmation: (req, res) ->
        mobile = req.param('mobile') or req.param('m') or false
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
                        res.negotiate err
                    if mobile
                        res.view 'msiteconfirm', {user: req.user, parcel: parcel, drivers: drivers, selected: driverId}
                    else
                        res.view 'siteconfirm', {user: req.user, parcel: parcel, drivers: drivers, selected: driverId}
        else
            if mobile
                res.redirect '/?m=1'
            else
                res.redirect '/'

    payment: (req, res) ->
        mobile = req.param('mobile') or req.param('m') or false
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
                        if mobile
                            res.view 'msitepayment', {user: req.user, parcel: parcel, request: request, driver: driver}
                        else
                            res.view 'sitepayment', {user: req.user, parcel: parcel, request: request, driver: driver}
        else
            if mobile
                res.redirect '/?m=1'
            else
                res.redirect '/'

    findPayment: (req, res) ->
        mobile = req.param('mobile') or req.param('m') or false
        parcelId = req.param('parcel')
        if parcelId
            Request.find({parcel: parcelId, senderAccepted: true}).exec (err, requests) ->
                if err?
                    console.log err
                    return res.negotiate err
                if requests? and requests.length > 0
                    if mobile
                        res.redirect '/payment/'+requests[0].id+'?m=1'
                    else
                        res.redirect '/payment/'+requests[0].id
        else
            if mobile
                res.redirect '/?m=1'
            else
                res.redirect '/'

    profile: (req, res) ->
        mobile = req.param('mobile') or req.param('m') or false
        if req.user?
            if mobile?
                res.view 'msiteprofile', {user: req.user}
            else
                res.view 'siteprofile', {user: req.user}
        else
            if mobile
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
        fromPerson = {firstname: data['fromPerson.firstName'], lastname: data['fromPerson.lastName'], phone: data['fromPerson.phone'], country: data['fromPerson.country'], city: data['fromPerson.city'], address1: data['fromPerson.address1'], address2: data['fromPerson.address2'], owner: req.user.id}
        toPerson = {firstname: data['toPerson.firstName'], lastname: data['toPerson.lastName'], phone: data['toPerson.phone'], country: data['toPerson.country'], city: data['toPerson.city'], address1: data['toPerson.address1'], address2: data['toPerson.address2'], owner: req.user.id}
        async.series( [
            (cb) ->
                if data.fromPersonProfile
                    return cb(null, null)
                else
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
