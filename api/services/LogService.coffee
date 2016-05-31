module.exports =
    saveLog: (type, method, argument) ->
        if typeof argument isnt 'string'
            objectid = argument.id
            argument = JSON.stringify(argument)
        else
            obj = JSON.parse argument
            objectid = obj.id
        Log.create({type: type, method: method, object: objectid, argument: argument}).exec (err, result) ->
            console.log err if err?
    
    lastLogs: (count, cb) ->
        if not count?
            count = 25
        Log.find({sort: 'createdAt DESC'}).limit(count).exec (err, result) ->
            console.log err if err?
            cb(err, result)

    logsForObject: (count, object, cb) ->
        if not count?
            count = 25
        Log.find({object: object, sort: 'createdAt DESC'}).limit(count).exec (err, result) ->
            console.log err if err?
            cb(err, result)

    cleanUp: ->
        # TODO
