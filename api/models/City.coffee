module.exports = 
    attributes:
        country:
            model: 'Country'
            required: true
        name:
            type: 'string'
            required: true
        class: 'string'
        zip: 'string'
        latitude: 
            type: 'number'
            defaultsTo: 0
        longitude:
            type: 'number'
            defaultsTo: 0
