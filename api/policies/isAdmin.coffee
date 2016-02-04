module.exports = (req, res, next) ->
    if req.isAuthenticated() and req.user.admin
        return next()
    else
        return res.redirect '/login'
        #return res.forbidden 'You are not permitted to perform this action'
