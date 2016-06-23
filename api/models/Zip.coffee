module.exports = 
    attributes:
        region:
            model: 'Region'
            required: true
        code:
            type: 'string'
            required: true
        latitude:
            type: 'float'
            defaultsTo: 0
        longitude:
            type: 'float'
            defaultsTo: 0
