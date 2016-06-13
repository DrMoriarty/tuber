module.exports =
    saveLog: (type, method, argument) ->
        if typeof argument isnt 'string'
            objectid = argument.id
            argument = JSON.stringify(argument)
        else
            try
                obj = JSON.parse argument
                objectid = obj.id
            catch error
                console.log 'Can not parse log argument'
        data = {type: type, method: method, argument: argument}
        if objectId?
            data.object = objectid
        Log.create(data).exec (err, result) ->
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
