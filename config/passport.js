var passport = require('passport'),
LocalStrategy = require('passport-local').Strategy,
FacebookStrategy = require('passport-facebook').Strategy
bcrypt = require('bcrypt');

passport.serializeUser(function(user, done) {
    done(null, user.id);
});

passport.deserializeUser(function(id, done) {
    User.findOne({ id: id } , function (err, user) {
        if(user.driver) {
            Parcel.count({driver: id, status: {'!': ['archive', 'canceled']}}).exec( function (err, count) {
                user.parcelCount = count;
                done(err, user);
            });
        } else {
            Parcel.count({owner: id, status: {'!': ['archive', 'canceled']}}).exec( function (err, count) {
                user.parcelCount = count;
                done(err, user);
            });
        }
    });
});

passport.use(new LocalStrategy({
    usernameField: 'login',
    passwordField: 'password'
  },
  function(login, password, done) {

    User.findOne({ login: login }, function (err, user) {
      if (err) { return done(err); }
      if (!user) {
        return done(null, false, { message: 'Incorrect login.' });
      }

      bcrypt.compare(password, user.password, function (err, res) {
          if (!res)
            return done(null, false, {
              message: 'Invalid Password'
            });
          var returnUser = {
            login: user.login,
            createdAt: user.createdAt,
            id: user.id
          };
          return done(null, returnUser, {
            message: 'Logged In Successfully'
          });
        });
    });
  }
));

passport.use(new FacebookStrategy({
    clientID: '905711859517805',
    clientSecret: '83643dddd7b6e575c4d8ed655750e6e3',
    callbackURL: "http://5.101.119.187/auth/facebook/callback"
  },
  function(accessToken, refreshToken, profile, done) {
      fname = profile.name.givenName;
      lname = profile.name.familyName;
      if(!fname) fname = profile.displayName;
      if(!lname) lname = "";
      User.findOrCreate({fbId: profile.id}, {fbId: profile.id, firstname: fname, lastname: lname}, function(err, user) {
          if (err) { return done(err); }
          done(null, user);
      });
  }
));
