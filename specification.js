const mongoose = require('mongoose');

const Schema = mongoose.Schema

const SpecSchema = Schema({
    shortDescription: [
        {
            type: Map,
            of: String
        }
    ]
})

const SpecificationModel = mongoose.model('Specification', SpecSchema)

module.exports = SpecificationModel