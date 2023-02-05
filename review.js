const mongoose = require('mongoose');

const Schema = mongoose.Schema

const ReviewSchema = Schema({
    pros: String,
    cons: String,
    comment: String,
    name: String,
    rating: Number
})

const Review = mongoose.model('Review', ReviewSchema)

module.exports = Review