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

    removeAbandonedParcels:
        schedule: '*/1 * * * *'
        onTick: ->
            pageSize = sails.config.tuberaddon.dbCleanPageSize
            page = sails.config.tuberaddon.dbCleanPageParcel
            Parcel.find({}).paginate({page:page, limit:pageSize}).populateAll().exec (err, result) ->
                if err? or not result? or result.length <= 0
                    console.log 'End of parcels. Set dbCleanPageParcel = 0.'
                    sails.config.tuberaddon.dbCleanPageParcel = 0
                else
                    idsForRemove = []
                    for parcel in result
                        if not parcel.owner?
                            idsForRemove.push parcel.id
                    console.log 'Page', page, '. Found', idsForRemove.length, idsForRemove, 'parcels for remove'
                    for id in idsForRemove
                        do (id) ->
                            Parcel.destroy({id: id}).exec (err, result) ->
                                console.log err if err?
                    sails.config.tuberaddon.dbCleanPageParcel = page+1

    removeAbandonedRequests:
        schedule: '*/1 * * * *'
        onTick: ->
            pageSize = sails.config.tuberaddon.dbCleanPageSize
            page = sails.config.tuberaddon.dbCleanPageRequest
            Request.find({}).paginate({page:page, limit:pageSize}).populateAll().exec (err, result) ->
                if err? or not result? or result.length <= 0
                    console.log 'End of requests. Set dbCleanPageRequest = 0.'
                    sails.config.tuberaddon.dbCleanPageRequest = 0
                else
                    idsForRemove = []
                    for request in result
                        if not request.parcel?
                            idsForRemove.push request.id
                    console.log 'Page', page, '. Found', idsForRemove.length, idsForRemove, 'requests for remove'
                    for id in idsForRemove
                        do (id) ->
                            Request.destroy({id: id}).exec (err, result) ->
                                console.log err if err?
                    sails.config.tuberaddon.dbCleanPageRequest = page+1
