soap = require 'soap'
{parseString} = require 'xml2js'
sprintf = require('sprintf-js').sprintf
request = require 'request'

module.exports =
    loginClient: (cb) ->
        if @_cachedLoginClient?
            cb @_cachedLoginClient
        else
            self = @
            soap.createClient 'https://public-ws-stage.dpd.com/services/LoginService/V2_0?wsdl', (err, client) ->
                self._cachedLoginClient = client
                console.log 'New client', client.describe()
                cb client

    login: (cb) ->
        DpdService.loginClient (client) ->
            args = {delisId: 'delti130', password: 'p9934g'}
            client.getAuth args, (err, result) ->
                if err?
                    console.log err
                    cb null
                else
                    console.log 'Dpd login', result
                    cb result
    
    getAuth: (cb) ->
        self = @
        username = 'delti130'
        #username = 'delticoma2'
        password = 'p9934g'
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
        request.post {url: 'https://public-ws-stage.dpd.com/services/LoginService/V2_0/getAuth', form: data}, (err, httpResponse, body) ->
            if err?
                console.log err
                cb err, null
            else
                console.log body
                parseString body, (err, result) ->
                    console.log 'XML to JSON', err, result
                    if err?
                        console.log err
                        cb err, body
                    else
                        cb null, result
                        token = result['soap:Envelope']['soap:Body'][0]['ns2:getAuthResponse'][0].return[0].authToken
                        self.authToken = token

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
                    self.storeOrderRequest result, cb
        if not @authToken?
            @getAuth (data) ->
                req()
        else
            req()

    storeOrderRequest: (parcel, cb) ->
        username = 'delti130'
        token = DpdService.authToken
        lang = 'en_US'   # en_US or de_DE
        fromAddress = parcel.fromPerson || parcel.owner
        toAddress = parcel.toPerson || parcel.owner
        parcelSizes = sprintf('%03d%03d%03d', parseInt(parcel.length), parseInt(parcel.width), parseInt(parcel.depth)) # in cm
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
                                <country>#{fromAddress.country}</country>
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
                                <country>#{toAddress.country}</country>
                                <zipCode>#{toAddress.zip}</zipCode>
                                <city>#{toAddress.city}</city>
                                <phone>#{toAddress.phone}</phone>
                                <email>#{toAddress.email}</email>
                            </recipient>
                        </generalShipmentData>
                        <parcels>
                            <parcelLabelNumber>00000000000</parcelLabelNumber>
                            <volume>#{parcelSizes}</volume>
                            <weight>#{parcel.weight}</weight>
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
        request.post {url:'https://public-ws-stage.dpd.com/services/ShipmentService/V3_2/storeOrders', form: data}, (err, httpResponse, body) ->
            if err?
                console.log err
                cb err, null
            else
                console.log body
                parseString body, (err, result) ->
                    console.log 'XML to JSON', err, result
                    if err?
                        console.log err
                        cb err, body
                    else
                        cb null, result

    getTrackingData: (labelNumber, cb) ->
        if not @authToken?
            self = @
            @getAuth (data) ->
                self.getTrackingDataRequest labelNumber, cb
        else
            @getTrackingDataRequest labelNumber, cb

    getTrackingDataRequest: (labelNumber, cb) ->
        username = 'delti130'
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
        request.post {url:'https://public-ws-stage.dpd.com/services/ParcelLifeCycleService/V2_0/getTrackingData', form: data}, (err, httpResponse, body) ->
            if err?
                console.log err
                cb err, null
            else
                console.log body
                parseString body, (err, result) ->
                    console.log 'XML to JSON', err, result
                    if err?
                        console.log err
                        cb err, body
                    else
                        cb null, result

    getParcelLabelNumber: (cb) ->
        username = 'delti130'
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
        request.post {url:'https://public-ws-stage.dpd.com/services/ParcelLifeCycleService/V2_0/getParcelLabelNumberForWebNumber', form: data}, (err, httpResponse, body) ->
            if err?
                console.log err
                cb err, null
            else
                console.log httpResponse
                console.log body
                cb null, body
        
