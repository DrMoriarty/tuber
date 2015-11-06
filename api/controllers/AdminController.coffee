
module.exports =
    main: (req, res) ->
        res.view 'blank', {user: req.user}

    profile: (req, res) ->
        res.view 'profile', {user: req.user}

    profileEdit: (req, res) ->
        res.view 'profileEdit', {user: req.user}

    countries: (req, res) ->
        res.view 'countries', {user: req.user}

    cities: (req, res) ->
        res.view 'cities', {user: req.user}

    parcel: (req, res) ->
        id = req.param('id')
        Parcel.findOne(id).populateAll().exec (err, result) ->
            console.log result
            if err or !result
                res.notFound()
            else
                res.view 'parcel', {user: req.user, result: result}
        
    parcels: (req, res) ->
        offset = req.param('offset') or 0
        Parcel.find().skip(offset).limit(50).populateAll().exec (err, result) ->
            res.view 'parcels', {user: req.user, result: result}

    newParcel: (req, res) ->
        User.find({driver: false}).exec (err, senders) ->
            res.view 'newParcel', {user: req.user, senders: senders}
        
    person: (req, res) ->
        id = req.param('id')
        Person.findOne(id).exec (err, result) ->
            if err or !result
                res.notFound()
            else
                res.view 'person', {user: req.user, result: result}

    persons: (req, res) ->
        res.view 'persons', {user: req.user}

    route: (req, res) ->
        id = req.param('id')
        Route.findOne(id).exec (err, result) ->
            if err or !result
                res.notFound()
            else
                res.view 'route', {user: req.user, result: result}

    routes: (req, res) ->
        res.view 'routes', {user: req.user}

    carrier: (req, res) ->
        id = req.param('id')
        User.findOne(id).exec (err, result) ->
            if err or !result
                res.notFound()
            else
                res.view 'carrier', {user: req.user, result: result}

    carriers: (req, res) ->
        offset = req.param('offset') or 0
        User.find({driver: true}).skip(offset).limit(50).exec (err, result) ->
            res.view 'carriers', {user: req.user, result: result}

    newCarrier: (req, res) ->
        res.view 'newcarrier', {user: req.user}

    sender: (req, res) ->
        id = req.param('id')
        User.findOne(id).exec (err, result) ->
            if err or !result
                res.notFound()
            else
                res.view 'sender', {user: req.user, result: result}

    senders: (req, res) ->
        offset = req.param('offset') or 0
        User.find({driver: false}).skip(offset).limit(50).exec (err, result) ->
            res.view 'senders', {user: req.user, result: result}

    newSender: (req, res) ->
        res.view 'newsender', {user: req.user}

    search: (req, res) ->
        res.view 'search', {user: req.user}

