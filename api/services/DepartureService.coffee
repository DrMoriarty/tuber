fs = require 'fs'

module.exports =
    processRequest: (requestId) ->
        Request.findOne(requestId).populateAll().exec (err, request) ->
            if err?
                console.log err
            else
                if request.driver.company == '__DPD__'
                    console.log 'Process DPD parcel'
                    DpdService.storeOrders request.parcel.id, (err, data) ->
                        if err?
                            console.log err
                        else
                            try
                                result = data['soap:Envelope']['soap:Body'][0]['ns2:storeOrdersResponse'][0].orderResult[0]
                                fileContent = new Buffer(result.parcellabelsPDF[0], 'base64')
                                fs.writeFile 'upload/'+request.parcel.id+'.pdf', fileContent, (err) ->
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
                            catch error
                                console.log error
                                LogService.saveLog 'Error', 'DPD processing', data
                else
                    console.log 'Private carrier. No need processing.'
