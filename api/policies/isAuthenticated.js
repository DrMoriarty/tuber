module.exports = function(req, res, next) {
    if (req.isAuthenticated()) {
        return next();
    }
    else {
        return res.forbidden('You are not permitted to perform this action.');
        //return res.redirect('/login');
    }
};
