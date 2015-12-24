 # SiteController
 #
 # @description :: Server-side logic for managing sites
 # @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

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
