"""
 AuthController

 @description :: Server-side logic for managing auths
 @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers
"""

passport = require 'passport'
facebookStrategy = require('passport-facebook').Strategy
uuid = require 'node-uuid'
generatePassword = require 'password-generator'

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
        email = req.param('email')
        if email?
            User.findOne({email: email}).exec (err, user) ->
                if err? or not user
                    console.log err
                    res.status(404)
                    res.json {error: 'Email not found'}
                else
                    hash = uuid.v1()
                    User.update({id: user.id}, {recoveryHash: hash}).exec (err, result) ->
                        if err?
                            console.log err
                            res.negotiate(err)
                        else
                            #MailingService.sendEmail email, 'Password recovery', 'Someone used your email address to recovery password. \nIf you want to reset your password go to this link\nhttp://packet24.com/recovery?hash='+hash
                            MailingService.processEvent user.email, 'passwordRestore', user.lang, '\nhttp://packet24.com/recovery?hash='+hash
                            res.json {status: 'Email was sent'}
        else
            res.status(400)
            res.json {error: 'Email required'}

    usePasswordRecovery: (req, res) ->
        hash = req.param('hash')
        if hash? and hash.length >= 36
            User.findOne({recoveryHash: hash}).exec (err, user) ->
                if err? or not user
                    console.log err
                    res.status(404)
                    res.json {error: 'Hash not found'}
                else
                    newpasswd = generatePassword(8)
                    User.update({id: user.id}, {password: newpasswd, recoveryHash: ''}).exec (err, result) ->
                        if err? or not result
                            console.log err
                            res.negotiate(err)
                        else
                            #MailingService.sendEmail user.email, 'Your shiny new password', 'For your account new password was set: ' + newpasswd
                            MailingService.processEvent user.email, 'passwordGenerated', user.lang, '\n' + newpasswd
                            if req.wantsJSON
                                res.json {status: 'Email with new password was sent'}
                            else
                                if req.mobile
                                    res.render 'msitepassword', {password: newpasswd}
                                else
                                    res.render 'sitepassword', {password: newpasswd}

        else
            res.status(400)
            res.json {error: 'Hash required'}

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
