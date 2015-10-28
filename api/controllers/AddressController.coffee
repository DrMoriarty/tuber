"""
 AddressController

 @description :: Server-side logic for managing addresses
 @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers
"""

blueprintsFind = require '../../node_modules/sails/lib/hooks/blueprints/actions/find'
blueprintsCreate = require '../../node_modules/sails/lib/hooks/blueprints/actions/create'
actionUtil = require '../../node_modules/sails/lib/hooks/blueprints/actionUtil'

module.exports = 
    find: (req, res) ->
        console.log 'Custom find action for address'
        if not req.user.admin
            req.params.ownerId = req.user.id
        return blueprintsFind(req, res)

    new: (req, res) ->
        console.log 'Custom create action for address'
        data = actionUtil.parseValues(req)
        console.log 'Data', data
        Address.create(data).exec( (err, newInstance) ->
            console.log 'Address created', newInstance
            if err
                return res.negotiate(err)
            res.created(newInstance)
        )
