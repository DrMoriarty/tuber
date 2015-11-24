module.exports =
    saveLog: (type, method, argument) ->
        if typeof argument isnt 'string'
            argument = JSON.stringify(argument)
        Log.create({type: type, method: method, argument: argument}).exec (err, result) ->
            console.log err if err?
    
    lastLogs: (count, cb) ->
        if not count?
            count = 25
        Log.find({sort: 'createdAt DESC'}).limit(count).exec (err, result) ->
            console.log err if err?
            cb(err, result)

    cleanUp: ->
        # TODO
