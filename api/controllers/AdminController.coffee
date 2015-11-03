
module.exports =
    main: (req, res) ->
        res.view 'blank', {user: req.user}

    country: (req, res) ->
        id = req.param('id')
        res.send 'TODO'

    city: (req, res) ->
        id = req.param('id')
        res.send 'TODO'

    parcel: (req, res) ->
        id = req.param('id')
        res.send 'TODO'
        
    person: (req, res) ->
        id = req.param('id')
        res.send 'TODO'

    route: (req, res) ->
        id = req.param('id')
        res.send 'TODO'

    carrier: (req, res) ->
        id = req.param('id')
        res.send 'TODO'

    sender: (req, res) ->
        id = req.param('id')
        res.send 'TODO'

    search: (req, res) ->
        res.send 'TODO'

