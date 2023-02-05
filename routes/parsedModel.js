const express = require("express");
const modelRouter = express.Router();
const ParsedModel = require('../model');
modelRouter.get('/parsedModels', async (req, res) => {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;

    const startIndex = (page - 1) * limit;
    const endIndex = page * limit;

    try {
        const parsedModels = await ParsedModel.find().skip(startIndex).limit(limit);
        res.status(200).json({
            parsedModels
        });
    } catch (error) {
        res.status(500).json({
            error: 'Internal server error'
        });
    }
});
modelRouter.get('/parsing', async (req, res) => {
    
});




// Create a new parsedModel
modelRouter.post('/parsedModel-create', async (req, res) => {
    
    const parsedModel = new ParsedModel({
        id: req.body.id,
        linkId: req.body.linkId,
        title: req.body.title,
        price: req.body.price,
        color: req.body.color,
        memory: req.body.memory,
        images: req.body.images,
        specification: req.body.specification,
        reviews: req.body.reviews
    });

    try {
        const savedParsedModel = await parsedModel.save();
        res.status(201).json({
            parsedModel: savedParsedModel
        });
    } catch (error) {
        res.status(400).json({
            error: 'Invalid request data'
        });
    }
});

// Get all parsedModels
modelRouter.get('/parsedModels', async (req, res) => {
    try {
        const parsedModels = await ParsedModel.find();
        res.status(200).json({
            parsedModels
        });
    } catch (error) {
        res.status(500).json({
            error: 'Internal server error'
        });
    }
});

// // Get a single parsedModel by id
// modelRouter.get('/parsedModel/:id', async (req, res) => {
//     try {
//         const parsedModel = await ParsedModel.findById(req.params.id);
//         res.status(200).json({
//             parsedModel
//         });
//     } catch (error) {
//         res.status(404).json({
//             error: 'ParsedModel not found'
//         });
//     }
// });

// Update a parsedModel
modelRouter.put('/parsedModel/:id', async (req, res) => {
    try {
        
        console.log(req.body);
        const updatedParsedModel = await ParsedModel.updateOne(
            {id: req.params.id}, {
                title: req.body.title,
                price: req.body.price,
            }
        );
        res.status(200).json({
            parsedModel: updatedParsedModel
        });
    } catch (error) {
        console.log(error);
        res.status(404).json({
            error: 'ParsedModel not found'
        });
    }
});





modelRouter.delete('/parsedmodel-delete/:id', async (req, res) => {
    const id = req.params.id;
    try {
        const result = await ParsedModel.deleteOne({ id: id });
        if (result.deletedCount === 0) {
            res.status(404).json({
                error: 'not found'
            });
        }
        res.status(200).json({
            successful: 'ParsedModel deleted'
        });
    } catch (error) {
        res.status(500).json({
            error: 'Server error'
        });
    }
});

module.exports = modelRouter