"""
 AuthController

 @description :: Server-side logic for managing auths
 @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers
"""

passport = require 'passport'
facebookStrategy = require('passport-facebook').Strategy

module.exports = 
	_config: 
        actions: false
        shortcuts: false
        rest: false
    login: (req, res) ->
        fn = passport.authenticate 'local', (err, user, info) ->
            #console.log err, user, info
            if err || !user
                return res.send
                    message: info.message
                    user: user
            req.logIn user, (err) ->
                if err
                    res.send(err)
                else
                    res.send
                        message: info.message
                        user: user
        fn(req, res)
    logout: (req, res) ->
        req.logout()
        res.redirect('/login')

    loginFb: (req, res) ->
        fn = passport.authenticate('facebook')
        fn(req, res)
    loginFbCallback: (req, res) ->
        fn = passport.authenticate('facebook', {successRedirect: '/', failureRedirect: '/login'})
        fn req, res, (err) ->
            if err
                console.log err

    generatePasswordRecovery: (req, res) ->
        # TODO
        res.send('TODO')

    usePasswordRecovery: (req, res) ->
        # TODO
        res.send('TODO')

    install: (req, res) ->
        User.findOne({admin: true}).exec (err, admin) ->
            if err? or !admin
                # create an admin
                User.create({firstname: 'Admin', lastname: 'Admin', email: 'admin@me.com', password: 'admin', admin: true, address1: 'Kremlin sq.', address2: 'bt. 1', zip: '160000', city: 'Vologda', country: 'Russia', phone: '01'}).exec (err, admin) ->
                    if err?
                        console.log err
                        res.send err
                    else
                        res.send 'Service successfully installed'
            else
                res.redirect('/')
