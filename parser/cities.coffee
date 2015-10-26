#!/opt/local/bin/coffee

request = require("request")
querystring = require("querystring")

API='http://localhost:1337/api/'
#API='http://5.178.85.110/api/'

checkAndSaveCity = (name, name_ru, latitude, longitude, countryID) ->
    name_q = querystring.escape(name)
    name_ru_q = querystring.escape(name_ru)
    request API+'city/?name='+name_q+'&country='+countryID, (err, resp, body) ->
        if err? or body == '[]'
            request API+'city/create?name='+name_q+'&name_ru='+name_ru_q+'&latitude='+latitude+'&longitude='+longitude+'&country='+countryID, (err, resp, body) ->
                if err?
                    console.log name, name_ru, err
                else
                    console.log body
        else
            console.log name, name_ru, 'already exist'
    
loadCitiesForCountry = (code, countryID) ->
    query = '[out:json]; area["ISO3166-1"="'+code+'"]; (node[place=city](area);); out body;'
    url = 'http://overpass.osm.rambler.ru/cgi/interpreter?data='+encodeURIComponent(query)

    request url, (err, resp, body) ->
        if err?
            console.log err
        else
            try
                result = JSON.parse body
                for city in result.elements
                    name = city.tags['name:en'] or city.tags['int_name'] or city.tags['name']
                    if code == 'RU'
                        name_ru = city.tags['name:ru'] or city.tags['name'] or city.tags['int_name']
                    else
                        name_ru = city.tags['name:ru'] or city.tags['int_name'] or city.tags['name']
                    latitude = city.lat
                    longitude = city.lon
                    console.log name, name_ru, latitude, longitude
                    checkAndSaveCity name, name_ru, latitude, longitude, countryID
                if result.elements.length <= 0
                    console.log 'Empty country:', code
            catch err
                if body[0] == '<'
                    # html error page
                    repeat = do(code, countryID) ->
                        () ->
                            console.log 'REPEAT: ', code
                            loadCitiesForCountry code, countryID
                    setTimeout repeat, 3000
                else
                    console.log code, err
                    console.log body


checkAllCountries = (onlyEmpty) ->
    request API+'country/?limit=0', (err, resp, body) ->
        if err?
            console.log err
        else
            result = JSON.parse body
            delay = 0
            for country in result
                ld = do (code = country.code, id = country.id) ->
                    () ->
                        loadCitiesForCountry code, id
                if not onlyEmpty
                    setTimeout ld, delay
                    delay += 3000
                else
                    do (code = country.code, id = country.id, ld) ->
                        request API+'city/?country='+id, (err, resp, body) ->
                            if err?
                                console.log err
                            else
                                if body == '[]'
                                    console.log 'Empty country: ', code
                                    setTimeout ld, delay
                                    delay += 3000

#loadCitiesForCountry 'RU', '5406b3dd6cbb2b0000d2f632'
#loadCitiesForCountry 'DE', '5580716f8f221c2939289e8e'

if process.argv.length <= 2
    checkAllCountries(false)
else
    code = process.argv[2]
    if code == 'empty' or code == 'empties'
        checkAllCountries(true)
    else
        request API+'country/?code='+code, (err, resp, body) ->
            if err?
                console.log err
            else if body != '[]'
                result = JSON.parse body
                console.log 'Try to load country', code, result[0].id
                loadCitiesForCountry code, result[0].id
