 # SiteController
 #
 # @description :: Server-side logic for managing sites
 # @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

moment = require 'moment'
async = require 'async'

module.exports = 
    home: (req, res) ->
        if req.user?
            if req.user.driver
                res.view 'sitedriver', {user: req.user}
            else
                res.view 'siteparcel', {user: req.user}
        else
            res.view 'sitelogin'

    faq: (req, res) ->
        res.view 'sitefaq'

    registration: (req, res) ->
        driver = req.param('driver') or false
        res.view 'sitereg', {driver: driver}

    parcel: (req, res) ->
        if req.user?
            res.view 'siteparcel', {user: req.user}
        else
            res.redirect '/'

    price: (req, res) ->
        if req.user?
            res.view 'siteprice', {user: req.user}
        else
            res.redirect '/'

    dashboard: (req, res) ->
        if req.user?
            res.view 'sitedashboard', {user: req.user}
        else
            res.redirect '/'

    confirmation: (req, res) ->
        if req.user?
            res.view 'siteconfirm', {user: req.user}
        else
            res.redirect '/'

    payment: (req, res) ->
        if req.user?
            res.view 'sitepayment', {user: req.user}
        else
            res.redirect '/'

    profile: (req, res) ->
        if req.user?
            res.view 'siteprofile', {user: req.user}

    parcel1: (req, res) ->
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

    parcel2: (req, res) ->
        #
        req.user.parcel2 = req.body
        console.log 'Parcel 1', req.user.parcel1
        console.log 'Parcel 2', req.user.parcel2
        res.json {status: 'ok'}
