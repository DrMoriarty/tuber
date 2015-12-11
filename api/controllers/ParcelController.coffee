"""
 ParcelController

 @description :: Server-side logic for managing parcels
 @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers
"""

blueprintsFindOne = require '../../node_modules/sails/lib/hooks/blueprints/actions/findOne'
actionUtil = require '../../node_modules/sails/lib/hooks/blueprints/actionUtil'
SkipperDisk = require('skipper-disk')

module.exports = 
    shipmentLabel: (req, res) ->
        parcelId = req.param('parcelId')
        Parcel.findOne(parcelId).exec (err, result) ->
            if err?
                res.negotiate err
            else if not result
                res.notFound()
            if result.shipment?.type? and result.shipment.type == 'DPD'
                file = SkipperDisk()
                file.read('upload/'+parcelId+'.pdf').on('error', (err) ->
                    res.serverError(err)
                ).pipe(res)
            else
                res.json {error: 'Parcel have not been shipped yet'}
                

    find: (req, res) ->
        if ( actionUtil.parsePk(req) ) 
            return blueprintsFindOne(req,res)

        data = actionUtil.parseCriteria(req)
        if not req.user.admin
            data.owner = req.user.id
        console.log 'Filter data', data
        query = Parcel.find()
            .where( data )
            .limit( actionUtil.parseLimit(req) )
            .skip( actionUtil.parseSkip(req) )
            .sort( actionUtil.parseSort(req) )
        #    .populateAll()
        query = actionUtil.populateEach(query, req)
        query.exec (err, matchingRecords) ->
            if (err)
                return res.serverError(err)
            res.ok(matchingRecords)

    create: (req, res) ->
        data = actionUtil.parseValues(req)
        if not req.user.admin
            data.owner = req.user.id
        else if !data.owner
            data.owner = req.user.id
        Parcel.create(data).exec( (err, newInstance) ->
            if err
                return res.negotiate(err)
            res.created(newInstance)
            console.log newInstance
        )
