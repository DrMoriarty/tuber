"""
 MessageController

 @description :: Server-side logic for managing messages
 @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers
"""

blueprintsFindOne = require '../../node_modules/sails/lib/hooks/blueprints/actions/findOne'
actionUtil = require '../../node_modules/sails/lib/hooks/blueprints/actionUtil'

module.exports = 
    find: (req, res) ->
        if ( actionUtil.parsePk(req) ) 
            return blueprintsFindOne(req,res)

        data = actionUtil.parseCriteria(req)
        if not req.user.admin
            data.sender = req.user.id
        console.log 'Filter data', data
        query = Message.find()
            .where( data )
            .limit( actionUtil.parseLimit(req) )
            .skip( actionUtil.parseSkip(req) )
            .sort( actionUtil.parseSort(req) )
        query = actionUtil.populateEach(query, req)
        query.exec (err, matchingRecords) ->
            if (err)
                return res.serverError(err)
            res.ok(matchingRecords)

    create: (req, res) ->
        data = actionUtil.parseValues(req)
        data.sender = req.user.id
        Message.create(data).exec( (err, newInstance) ->
            if err
                return res.negotiate(err)
            res.created(newInstance)
            console.log newInstance
        )
