const mongoose = require('mongoose');
const Review = require('./review');
const SpecificationModel = require('./specification');
const Schema = mongoose.Schema

const Model = Schema({
    id: {
        required: true,
        type: String,
        unique:true
    },
    linkId: {
        required: true,
        type: String,
        unique:true
    },
    title: {
        required: true,
        type: String,
    },
    price: String,
    color: [String],
    memory: [String],
    images: [String],
    specification: [SpecificationModel.schema],
    reviews: [Review.schema]
})
const ParsedModel = mongoose.model('parsedModel', Model)

module.exports = ParsedModel

//https://api.technodom.kz/feedback/api/v2/reviews/products/263257?limit=10&page=1&mood=&with_photo=
//https://api.technodom.kz/katalog/api/v1/products/category/smartfony-i-gadzhety?city_id=5f5f1e3b4c8a49e692fefd70&limit=24&sorting=score&price=0
//https://api.technodom.kz/katalog/api/v1/products/category/smartfony-i-telefony?city_id=5f5f1e3b4c8a49e692fefd70&limit=24&sorting=score&price=0&page=2
//
