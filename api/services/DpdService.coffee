soap = require 'soap'
{parseString} = require 'xml2js'
sprintf = require('sprintf-js').sprintf
request = require 'request'
iconv = require 'iconv-lite'

roundInt = (x) ->
    x = Number(x)
    (if x >= 0 then Math.floor(x) else Math.ceil(x))

#dpdUserName = '2406008738'
#dpdPassword = 'kxra4'

#API_DPD = 'https://public-ws-stage.dpd.com/'
API_DPD = 'https://public-ws.dpd.com/'

module.exports =
    company: '__DPD__'
    loginClient: (cb) ->
        if @_cachedLoginClient?
            cb @_cachedLoginClient
        else
            self = @
            soap.createClient API_DPD+'services/LoginService/V2_0?wsdl', (err, client) ->
                self._cachedLoginClient = client
                console.log 'New client', client.describe()
                cb client

    login: (cb) ->
        DpdService.loginClient (client) ->
            args = {delisId: sails.config.tuber.dpd.dpdUserName, password: sails.config.tuber.dpd.dpdPassword}
            client.getAuth args, (err, result) ->
                if err?
                    console.log err
                    cb null
                else
                    console.log 'Dpd login', result
                    cb result
    
    getAuth: (cb) ->
        self = @
        username = sails.config.tuber.dpd.dpdUserName
        password = sails.config.tuber.dpd.dpdPassword
        lang = 'en_US'   # en_US or de_DE
        data = """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://dpd.com/common/service/types/LoginService/2.0">
            <soapenv:Header/>
            <soapenv:Body>
                <ns:getAuth>
                    <delisId>#{username}</delisId>
                    <password>#{password}</password>
                    <messageLanguage>#{lang}</messageLanguage>
                </ns:getAuth>
            </soapenv:Body>
        </soapenv:Envelope>
        """
        console.log 'Request data:', data
        request.post {encoding: null, url: API_DPD+'services/LoginService/V2_0/getAuth', form: data}, (err, httpResponse, body) ->
            if err?
                console.log err
                cb err, null
            else
                body = iconv.decode(body, 'iso-8859-1')
                console.log '[getAuth]: ', body
                parseString body, (err, result) ->
                    console.log 'XML to JSON', err, result
                    if err?
                        console.log err
                        cb err, body
                    else
                        token = result['soap:Envelope']['soap:Body'][0]['ns2:getAuthResponse'][0].return[0].authToken
                        self.authToken = token
                        cb null, result

    storeOrders: (parcelId, cb) ->
        self = @
        if not parcelId?
            return cb {error: 'Parcel not defined'}, null
        req = ->
            Parcel.findOne(parcelId).populateAll().exec (err, result) ->
                if err?
                    console.log err
                    cb err, null
                else
                    if not result.fromPerson? and not result.toPerson?
                        return cb {error: 'Departure or shipment address not found', parcel: result}, null
                    if result.shipment?.type?
                        return cb {error: 'The parcel already shipped', parcel: result}, null
                    self.storeOrderRequest result, cb
        if not @authToken? or true
            @getAuth (data) ->
                req()
        else
            req()

    storeOrderRequest: (parcel, cb) ->
        username = sails.config.tuber.dpd.dpdUserName
        token = DpdService.authToken
        lang = 'en_US'   # en_US or de_DE
        fromAddress = parcel.fromPerson || parcel.owner
        toAddress = parcel.toPerson || parcel.owner
        parcelSizes = sprintf('%03d%03d%03d', parseInt(parcel.length), parseInt(parcel.width), parseInt(parcel.depth)) # in cm
        weight = roundInt(parcel.weight * 100)
        fromAddress.zip = fromAddress.zip or ''
        fromAddress.phone = fromAddress.phone or ''
        fromAddress.email = fromAddress.email or ''
        toAddress.zip = toAddress.zip or ''
        toAddress.phone = toAddress.phone or ''
        toAddress.email = toAddress.email or ''
        data = 
        """<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://dpd.com/common/service/types/Authentication/2.0" xmlns:ns1="http://dpd.com/common/service/types/ShipmentService/3.2">
            <soapenv:Header>
                <ns:authentication>
                    <delisId>#{username}</delisId>
                    <authToken>#{token}</authToken>
                    <messageLanguage>#{lang}</messageLanguage>
                </ns:authentication>
            </soapenv:Header>
            <soapenv:Body>
                <ns1:storeOrders>
                    <printOptions>
                        <printerLanguage>PDF</printerLanguage>
                        <paperFormat>A4</paperFormat>
                    </printOptions>
                    <order>
                        <generalShipmentData>
                            <identificationNumber>#{parcel.id}</identificationNumber>
                            <sendingDepot>0163</sendingDepot>
                            <product>CL</product>
                            <mpsCompleteDelivery>0</mpsCompleteDelivery>
                            <sender>
                                <name1>#{fromAddress.firstname}</name1>
                                <name2>#{fromAddress.lastname}</name2>
                                <street>#{fromAddress.address1}</street>
                                <houseNo>#{fromAddress.address2}</houseNo>
                                <country>#{fromAddress.countryCode}</country>
                                <zipCode>#{fromAddress.zip}</zipCode>
                                <city>#{fromAddress.city}</city>
                                <customerNumber>12345679</customerNumber>
                                <phone>#{fromAddress.phone}</phone>
                                <email>#{fromAddress.email}</email>
                            </sender>
                            <recipient>
                                <name1>#{toAddress.firstname}</name1>
                                <name2>#{toAddress.lastname}</name2>
                                <street>#{toAddress.address1}</street>
                                <houseNo>#{toAddress.address2}</houseNo>
                                <country>#{toAddress.countryCode}</country>
                                <zipCode>#{toAddress.zip}</zipCode>
                                <city>#{toAddress.city}</city>
                                <phone>#{toAddress.phone}</phone>
                                <email>#{toAddress.email}</email>
                            </recipient>
                        </generalShipmentData>
                        <parcels>
                            <parcelLabelNumber>00000000000</parcelLabelNumber>
                            <volume>#{parcelSizes}</volume>
                            <weight>#{weight}</weight>
                            <addService>1</addService>
                        </parcels>
                        <productAndServiceData>
                            <orderType>consignment</orderType>
                        </productAndServiceData>
                    </order>
                </ns1:storeOrders>
            </soapenv:Body>
        </soapenv:Envelope>"""

        """
                            <proactiveNotification>
                                <channel>3</channel>
                                <value>#{parcel.owner.phone}</value>
                                <rule>7</rule>
                                <language>DE</language>
                            </proactiveNotification>
        """
        console.log 'Store order request data', data
        request.post {encoding: null, url:API_DPD+'services/ShipmentService/V3_2/storeOrders', form: data}, (err, httpResponse, body) ->
            if err?
                console.log err
                cb err, null
            else
                body = iconv.decode(body, 'iso-8859-1')
                console.log body
                parseString body, (err, result) ->
                    console.log 'XML to JSON', err, result
                    if err?
                        console.log err
                        cb err, body
                    else
                        cb null, result

    getTrackingData: (labelNumber, cb) ->
        if not @authToken? or true
            self = @
            @getAuth (data) ->
                self.getTrackingDataRequest labelNumber, cb
        else
            @getTrackingDataRequest labelNumber, cb

    getTrackingDataRequest: (labelNumber, cb) ->
        username = sails.config.tuber.dpd.dpdUserName
        token = DpdService.authToken
        lang = 'en_EN'   # en_US or de_DE
        data = """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://dpd.com/common/service/types/Authentication/2.0" xmlns:ns1="http://dpd.com/common/service/types/ParcelLifeCycleService/2.0">
            <soapenv:Header>
                <ns:authentication>
                    <delisId>#{username}</delisId>
                    <authToken>#{token}</authToken>
                    <messageLanguage>#{lang}</messageLanguage>
                </ns:authentication>
            </soapenv:Header>
            <soapenv:Body>
                <ns1:getTrackingData>
                    <parcelLabelNumber>#{labelNumber}</parcelLabelNumber>
                </ns1:getTrackingData>
            </soapenv:Body>
        </soapenv:Envelope>
        """
        request.post {encoding: null, url:API_DPD+'services/ParcelLifeCycleService/V2_0/getTrackingData', form: data}, (err, httpResponse, body) ->
            if err?
                console.log err
                cb err, null
            else
                body = iconv.decode(body, 'iso-8859-1')
                console.log body
                parseString body, (err, result) ->
                    console.log 'XML to JSON', err, result
                    if err?
                        console.log err
                        cb err, body
                    else
                        cb null, result

    getParcelLabelNumber: (cb) ->
        username = sails.config.tuber.dpd.dpdUserName
        webnumber = 'IO1234567'
        data = """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://dpd.com/common/service/types/ParcelLifeCycleService/2.0">
            <soapenv:Header/>
            <soapenv:Body>
                <ns:getParcelLabelNumberForWebNumber>
                    <webNumber>#{webnumber}</webNumber>
                </ns:getParcelLabelNumberForWebNumber>
            </soapenv:Body>
        </soapenv:Envelope>
        """
        request.post {encoding: null, url:API_DPD+'services/ParcelLifeCycleService/V2_0/getParcelLabelNumberForWebNumber', form: data}, (err, httpResponse, body) ->
            if err?
                console.log err
                cb err, null
            else
                body = iconv.decode(body, 'iso-8859-1')
                console.log httpResponse
                console.log body
                cb null, body
        
    #
    # Find the DPD parcel shops by country/countries, zipCode and city and additional criteria like flags for properties of parcel shops. The search country can either domestic country or cross border country/countries for the search.
    # 
    findParcelShops: (cb) ->
        if not @authToken? or true
            self = @
            @getAuth (data) ->
                self.findParcelShopsRequest cb
        else
            @findParcelShopsRequest cb

    findParcelShopsRequest: (cb) ->
        username = sails.config.tuber.dpd.dpdUserName
        token = DpdService.authToken
        lang = 'en_US'   # en_US or de_DE
        data = """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://dpd.com/common/service/types/Authentication/2.0" xmlns:ns1="http://dpd.com/common/service/types/ParcelShopFinderService/5.0">
            <soapenv:Header>
                <ns:authentication>
                    <delisId>#{username}</delisId>
                    <authToken>#{token}</authToken>
                    <messageLanguage>#{lang}</messageLanguage>
                </ns:authentication>
            </soapenv:Header>
            <soapenv:Body>
                <ns1:findParcelShops>
                    <country>DE</country>
                    <zipCode>60388</zipCode>
                    <street>Casimirstraße</street>
                    <limit>10</limit>
                    <availabilityDate>2014-11-10 16:00</availabilityDate>
                    <hideClosed>true</hideClosed>
                </ns1:findParcelShops>
            </soapenv:Body>
        </soapenv:Envelope>
        """
        request.post {encoding: null, url:API_DPD+'services/ParcelShopFinderService/V5_0/findParcelShops', form: data}, (err, httpResponse, body) ->
            if err?
                console.log err
                cb err, null
            else
                body = iconv.decode(body, 'iso-8859-1')
                console.log '[findParcelShops]: ', body
                parseString body, (err, result) ->
                    console.log 'XML to JSON', err, result
                    if err?
                        console.log err
                        cb err, body
                    else
                        cb null, result

    #
    # Find the DPD parcel shops by geo data and additional criteria like flags for properties of parcel shops. The search country can either domestic country or cross border country/countries for the search.
    # 
    findParcelShopsByGeoData: (lat, lng, cb) ->
        if not @authToken? or true
            self = @
            @getAuth (data) ->
                self.findParcelShopsByGeoDataRequest lat, lng, cb
        else
            @findParcelShopsByGeoDataRequest lat, lng, cb

    findParcelShopsByGeoDataRequest: (lat, lng, cb) ->
        username = sails.config.tuber.dpd.dpdUserName
        token = DpdService.authToken
        lang = 'en_US'   # en_US or de_DE
        data = """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://dpd.com/common/service/types/Authentication/2.0" xmlns:ns1="http://dpd.com/common/service/types/ParcelShopFinderService/5.0">
            <soapenv:Header>
                <ns:authentication>
                    <delisId>#{username}</delisId>
                    <authToken>#{token}</authToken>
                    <messageLanguage>#{lang}</messageLanguage>
                </ns:authentication>
            </soapenv:Header>
            <soapenv:Body>
                <ns1:findParcelShopsByGeoData>
                    <longitude>#{lng}</longitude>
                    <latitude>#{lat}</latitude>
                    <limit>3</limit>
                </ns1:findParcelShopsByGeoData>
            </soapenv:Body>
        </soapenv:Envelope>
        """
        console.log 'Request data:', data
        request.post {encoding: null, url:API_DPD+'services/ParcelShopFinderService/V5_0/findParcelShopsByGeoData', form: data}, (err, httpResponse, body) ->
            if err?
                console.log err
                cb err, null
            else
                body = iconv.decode(body, 'iso-8859-1')
                console.log body
                parseString body, (err, result) ->
                    console.log 'XML to JSON', err, result
                    if err?
                        console.log err
                        cb err, body
                    else
                        cb null, result

    #
    # Find cities with DPD parcel shops by country, zipCode and city.
    # 
    findCities: (cb) ->
        if not @authToken? or true
            self = @
            @getAuth (data) ->
                self.findCitiesRequest cb
        else
            @findCitiesRequest cb

    findCitiesRequest: (cb) ->
        username = sails.config.tuber.dpd.dpdUserName
        token = DpdService.authToken
        lang = 'en_US'   # en_US or de_DE
        data = """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://dpd.com/common/service/types/Authentication/2.0" xmlns:ns1="http://dpd.com/common/service/types/ParcelShopFinderService/5.0">
            <soapenv:Header>
                <ns:authentication>
                    <delisId>#{username}</delisId>
                    <authToken>#{token}</authToken>
                    <messageLanguage>#{lang}</messageLanguage>
                </ns:authentication>
            </soapenv:Header>
            <soapenv:Body>
                <ns1:findCities>
                    <country>DE</country>
                    <zipCode>63741</zipCode>
                    <city>Aschaffenburg</city>
                    <limit>1</limit>
                    <order>NAME</order>
                </ns1:findCities>
            </soapenv:Body>
        </soapenv:Envelope>
        """
        request.post {encoding: null, url:API_DPD+'services/ParcelShopFinderService/V5_0/findCities', form: data}, (err, httpResponse, body) ->
            if err?
                console.log err
                cb err, null
            else
                body = iconv.decode(body, 'iso-8859-1')
                console.log body
                parseString body, (err, result) ->
                    console.log 'XML to JSON', err, result
                    if err?
                        console.log err
                        cb err, body
                    else
                        cb null, result

    #
    # Find available services of DPD parcel shops by country.
    #
    getAvailableServices: (cb) ->
        if not @authToken? or true
            self = @
            @getAuth (data) ->
                self.getAvailableServicesRequest cb
        else
            @getAvailableServicesRequest cb

    getAvailableServicesRequest: (cb) ->
        username = sails.config.tuber.dpd.dpdUserName
        token = DpdService.authToken
        lang = 'en_US'   # en_US or de_DE
        data = """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://dpd.com/common/service/types/Authentication/2.0" xmlns:ns1="http://dpd.com/common/service/types/ParcelShopFinderService/5.0">
            <soapenv:Header>
                <ns:authentication>
                    <delisId>#{username}</delisId>
                    <authToken>#{token}</authToken>
                    <messageLanguage>#{lang}</messageLanguage>
                </ns:authentication>
            </soapenv:Header>
            <soapenv:Body>
                <ns1:getAvailableServices />
            </soapenv:Body>
        </soapenv:Envelope>
        """
        request.post {encoding: null, url:API_DPD+'services/ParcelShopFinderService/V5_0/getAvailableServices', form: data}, (err, httpResponse, body) ->
            if err?
                console.log err
                cb err, null
            else
                body = iconv.decode(body, 'iso-8859-1')
                console.log body
                parseString body, (err, result) ->
                    console.log 'XML to JSON', err, result
                    if err?
                        console.log err
                        cb err, body
                    else
                        cb null, result

