"""
 RequestController

 @description :: Server-side logic for managing requests
 @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers
"""

blueprintsFindOne = require '../../node_modules/sails/lib/hooks/blueprints/actions/findOne'
actionUtil = require '../../node_modules/sails/lib/hooks/blueprints/actionUtil'

module.exports = 
    find: (req, res) ->
        if ( actionUtil.parsePk(req) ) 
            return blueprintsFindOne(req,res)

        data = actionUtil.parseCriteria(req)
        findOb = {}
        if not req.user.admin
            findOb = {$or: [{driver: req.user.id}, {sender: req.user.id}]}
        console.log 'Filter data', data
        query = Request.find(findOb)
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
        if not req.user.admin
            if data.driver != req.user.id and data.sender != req.user.id
                return res.json {error: 'Operation not permitted'}
        Request.create(data).exec( (err, newInstance) ->
            if err
                return res.negotiate(err)
            res.created(newInstance)
            console.log newInstance
        )


