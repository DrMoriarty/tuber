#!/opt/local/bin/coffee

request = require("request")
querystring = require("querystring")
async = require 'async'

#API='http://localhost:1337/'
API='http://5.101.119.187/'

DEBUG = false

testlist = [
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

performTest = (test, cb) ->
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

performSequence = (sequence, cb) ->
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
            performTest item, (res, err) ->
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

performSequenceSerie = (sequence, number, cb) ->
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
        performSequence sequence, (res) ->
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
                result.serverTime /= result.requests * 1000
                result.clientTime /= result.requests * 1000
                result.maxClientTime /= 1000
                result.maxServerTime /= 1000
                cb result

performComplexTest = (series, cb) ->
    results = []    
    async.eachSeries series,
        (it, callback) ->
            performSequenceSerie it.list, it.count, (res) ->
                results.push res
                callback()
        () ->
            cb(results)

MAXTEST = 100

for arg in process.argv
    if arg == '-d'
        DEBUG = true
    if arg.indexOf('-t=') == 0
        MAXTEST = parseInt(arg.substring(3))

complex = []
step = MAXTEST / 10 or 1
count = step

for i in [0...10]
    complex.push {list: testlist, count:count}
    count += step

performComplexTest complex, (res) ->
    console.log res

