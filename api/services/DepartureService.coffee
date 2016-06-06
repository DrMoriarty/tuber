fs = require 'fs'

dpd_prices = JSON.parse(fs.readFileSync('dpd_prices.json', 'utf8'));

module.exports =
    priceCalc:(driver, parcel) ->
        if driver.company == DpdService.company
            if dpd_prices? and dpd_prices.length > 0
                price = 0
                for dp in dpd_prices
                    if price == 0 and parcel.weight <= dp.weight
                        price = dp.price
                if price == 0
                    price = dpd_prices[dpd_prices.length-1].price
                return price
            else
                console.log 'Can not DPD custom prices. Using default price calculation.'
                return if driver.defaultPrice > 0 then driver.defaultPrice else driver.pricePerKm * parcel.pathLength
        else
            if driver.defaultPrice > 0 then driver.defaultPrice else driver.pricePerKm * parcel.pathLength
    processRequest: (requestId) ->
        Request.findOne(requestId).populateAll().exec (err, request) ->
            if err?
                console.log err
            else
                if request.driver.company == DpdService.company
                    console.log 'Process DPD parcel'
                    DpdService.storeOrders request.parcel.id, (err, data) ->
                        if err?
                            console.log err
                        else
                            try
                                result = data['soap:Envelope']['soap:Body'][0]['ns2:storeOrdersResponse'][0].orderResult[0]
                                fileContent = new Buffer(result.parcellabelsPDF[0], 'base64')
                                fname = 'upload/'+request.parcel.id+'.pdf'
                                fs.writeFile fname, fileContent, (err) ->
                                    console.log err if err?
                                shipmentData =
                                    type: 'DPD'
                                    identificationNumber: result.shipmentResponses[0].identificationNumber[0]
                                    mpsId: result.shipmentResponses[0].mpsId[0]
                                    parcelLabelNumber: result.shipmentResponses[0].parcelInformation[0].parcelLabelNumber[0]
                                console.log 'Shipment data', shipmentData
                                Parcel.update({id: request.parcel.id}, {shipment: shipmentData}).exec (err, result) ->
                                    console.log err if err?
                                Request.update({id: requestId}, {trackingNumber: shipmentData.parcelLabelNumber}).exec (err, res) ->
                                    console.log err if err?
                                Parcel.findOne(request.parcel.id).populateAll().exec (err, parcel) ->
                                    MailingService.processEvent parcel.owner.email, 'orderPlaced', parcel.owner.lang, {'INFO': sails.getBaseURL()+'/'+fname}
                            catch error
                                console.log error
                                LogService.saveLog 'Error', 'DPD processing', data
                else
                    console.log 'Private carrier. No need processing.'
