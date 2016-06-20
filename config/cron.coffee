moment = require 'moment'

module.exports.cron =
    driverAcceptTimeout:
        schedule: '*/5 * * * *'  # every five minutes
        onTick: ->
            console.log 'Checking for outdated requests'
            now = new Date()
            User.find({driver: true, company: DpdService.company}).exec (err, drivers) ->
                if err or not drivers or drivers.length <= 0
                    console.log err
                else
                    dpdDriver = drivers[0]
                    console.log 'Get DPD carrier', dpdDriver.id
                    Request.find({driverAcceptTimeout: {'<=': now}, driverAccepted: false}).populateAll().exec (err, result) ->
                        console.log 'Outdated requests:', result
                        for outdated in result
                            if not outdated.parcel?
                                continue
                            newRequest =
                                parcel: outdated.parcel.id
                                driver: dpdDriver.id
                                sender: outdated.parcel.owner
                                senderAccepted: false
                                price: dpdDriver.getPrice(outdated.parcel)
                                deliveryPrice: dpdDriver.getDeliveryPrice(outdated.parcel)
                                deliveryOption: 'home'
                            console.log 'New request', newRequest
                            Request.create(newRequest).exec (err, result) ->
                                if err or not result
                                    console.log err
                                else
                                    SearchService.acceptDriver dpdDriver.id, outdated.parcel.id, (err, result) ->
                                        console.log err if err
                
    archiveParcels:
        schedule: '*/10 * * * *'  #every ten minutes
        onTick: ->
            timeout = sails.config.tuber.archiveParcelTime
            tlim = moment().subtract(timeout, 'h').toDate()
            Parcel.find({status: 'arrived', updatedAt: {'<=': tlim}}).exec (err, parcels) ->
                for parcel in parcels
                    console.log 'Move outdated parcel to archive', parcel
                    Parcel.update({id: parcel.id}, {status: 'archive'}).exec (err, result) ->
                        console.log err if err?
