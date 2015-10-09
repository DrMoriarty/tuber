"""
 AuthController

 @description :: Server-side logic for managing auths
 @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers
"""

passport = require 'passport'

module.exports = 
	_config: 
        actions: false
        shortcuts: false
        rest: false
    login: (req, res) ->
        passport.authenticate 'local', (err, user, info) ->
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
    logout: (req, res) ->
        req.logout()
        res.redirect('/')

    generatePasswordRecovery: (req, res) ->
        # TODO
        res.send('TODO')

    usePasswordRecovery: (req, res) ->
        # TODO
        res.send('TODO')
