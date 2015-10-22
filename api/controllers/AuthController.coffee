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
        #console.log 'Log in user', req.params
        fn = passport.authenticate 'local', (err, user, info) ->
            console.log user, info
            if err || !user
                return res.send
                    message: info.message
                    user: user
            req.logIn user, (err) ->
                if err
                    res.send(err)
                res.send
                    message: info.message
                    user: user
        fn(req, res)
    logout: (req, res) ->
        req.logout()
        res.redirect('/')

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
