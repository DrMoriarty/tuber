request = require("request")
querystring = require("querystring")
async = require 'async'

API='http://localhost:1337/'
#API='http://5.178.85.110/'

DEBUG = false
MAXTEST = 100

module.exports =
    defaultTestList: [
        {
            url: 'login'
            method: 'POST'
            data:
                email: 'admin@me.com'
                password: 'admin'
        }
        {
            url: 'api/address'
        }
        {
            url: 'api/city'
        }
        {
            url: 'api/country'
        }
        {
            url: 'api/message'
        }
        {
            url: 'api/parcel'
        }
        {
            url: 'api/person'
        }
        {
            url: 'api/request'
        }
        {
            url: 'api/user'
        }
        {
            url: 'logout'
        }
    ]

    performTest: (test, cb) ->
        startTime = new Date()
        console.log 'Test', test if DEBUG
        if test.method? and test.method == 'POST'
            # POST
            request.post {url: API+test.url, form: test.data, jar: test.jar}, (err, httpResponse, body) ->
                if err
                    console.log 'POST error', err if DEBUG
                    return cb null, err
                else
                    res = {clientTime: new Date() - startTime, serverTime: parseFloat(httpResponse.headers['x-response-time'])}
                    if httpResponse.statusCode == 200
                        console.log 'POST result', httpResponse.statusCode if DEBUG
                        console.log httpResponse.headers if DEBUG
                        console.log body if DEBUG
                        return cb res, null
                    else
                        console.log 'POST err', httpResponse.statusCode if DEBUG
                        console.log body if DEBUG
                        return cb res, httpResponse.statusCode
        else
            # GET
            request {url: API+test.url, jar: test.jar}, (err, httpResponse, body) ->
                if err?
                    console.log 'GET error', err if DEBUG
                    cb null, err
                else
                    res = {clientTime: new Date() - startTime, serverTime: parseFloat(httpResponse.headers['x-response-time'])}
                    if httpResponse.statusCode == 200
                        console.log 'GET result', httpResponse.statusCode if DEBUG
                        console.log httpResponse.headers if DEBUG
                        console.log body if DEBUG
                        return cb res, null
                    else
                        console.log 'GET err', httpResponse.statusCode if DEBUG
                        console.log body if DEBUG
                        return cb res, httpResponse.statusCode
    
    performSequence: (sequence, cb) ->
        result = {
            serverTime: 0
            clientTime: 0
            series: 0
            requests: 0
            errors: 0
            maxClientTime: 0
            maxServerTime: 0
        }
        jar = request.jar()
        async.eachSeries sequence,
            (item, callback) ->
                # call one test
                item.jar = jar
                TestService.performTest item, (res, err) ->
                    result.requests += 1
                    if err?
                        result.errors += 1
                    if not res?
                        console.log 'Test failed'
                    else
                        result.clientTime += res.clientTime
                        result.serverTime += res.serverTime
                        if res.clientTime > result.maxClientTime
                            result.maxClientTime = res.clientTime
                        if res.serverTime > result.maxServerTime
                            result.maxServerTime = res.serverTime
                        console.log 'Result', res if DEBUG
                    callback()
            () ->
                # done
                cb result
    
    performSequenceSerie: (sequence, number, cb) ->
        result = {
            serverTime: 0
            clientTime: 0
            series: 0
            requests: 0
            errors: 0
            maxClientTime: 0
            maxServerTime: 0
        }
        for i in [0...number]
            TestService.performSequence sequence, (res) ->
                if not res?
                    console.log 'Test sequence failed'
                else
                    result.requests += res.requests
                    result.errors += res.errors
                    result.clientTime += res.clientTime
                    result.serverTime += res.serverTime
                    if res.clientTime > result.maxClientTime
                        result.maxClientTime = res.clientTime
                    if res.serverTime > result.maxServerTime
                        result.maxServerTime = res.serverTime
                result.series += 1
                if result.series >= number
                    result.serverTime = result.serverTime / result.requests / 1000
                    result.clientTime = result.clientTime / result.requests / 1000
                    result.maxServerTime /= 1000
                    result.maxClientTime /= 1000
                    cb result
    
    performComplexTest: (series, cb) ->
        results = []    
        async.eachSeries series,
            (it, callback) ->
                list = it.list or TestService.defaultTestList
                count = it.count or 10
                TestService.performSequenceSerie list, count, (res) ->
                    results.push res
                    callback()
            () ->
                cb(results)

    sendEmail: (email, notificationType, language) ->
        info = ''
        switch
            when notificationType == 'registrationComplete' then info = ''
            when notificationType == 'registrationCompleteCarrier' then info = ''
            when notificationType == 'passwordRestore' then info = sails.getBaseURL() + '/recovery?hash=0987654321'
            when notificationType == 'passwordGenerated' then info = 'YOURNEWPASSWORD'
            when notificationType == 'driverNeedAccept' then info = ''
            when notificationType == 'senderWaitingForAccept' then info = ''
            when notificationType == 'orderAccepted' then info = 'Parcel shop address'
            when notificationType == 'orderPayed' then info = ''
            when notificationType == 'orderPlaced' then info = sails.getBaseURL() + '/upload/349849238479.pdf'
            when notificationType == 'orderArrived' then info = ''
        MailingService.processEvent email, notificationType, language, {'INFO': info, USERNAME: 'Admin'}
    
    
#performComplexTest [{list: testlist, count:10}, {list: testlist, count:25}, {list: testlist, count:50}, {list: testlist, count:100}], (res) ->
#    console.log res
