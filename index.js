const fs = require('fs');
const puppeteer = require('puppeteer');
const https = require('https');
const axios = require('axios');
const SpecificationModel = require('./specification');
const Review = require('./review');
const ParsedModel = require('./model');
const express = require("express");
const {
    default: mongoose
} = require('mongoose');
const modelRouter = require('./routes/parsedModel');
const PORT = process.env.PORT || 3000;
const app = express();

const DB =
    "mongodb://localhost:27017/endterm";

// let url = 'https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY'
let link = "https://www.technodom.kz/catalog/noutbuki-i-komp-jutery/noutbuki-i-aksessuary?page=";
// let link = "https://www.technodom.kz/catalog/smartfony-i-gadzhety/smartfony-i-telefony/smartfony?page=";

let api = 'https://api.technodom.kz/katalog/api/v1/products/category/noutbuki-i-aksessuary?city_id=5f5f1e3b4c8a49e692fefd70&limit=24&sorting=score&price=0&page=';
// let api = 'https://api.technodom.kz/katalog/api/v1/products/category/smartfony-i-telefony?city_id=5f5f1e3b4c8a49e692fefd70&limit=24&sorting=score&price=0&page=';

app.use(express.json());
app.use(modelRouter)

// 24*12 noutbooks
mongoose
    .connect(DB)
    .then(() => {
        console.log("Connection Successful");
    })
    .catch((e) => {
        console.log(e);
    });

function reviewApi(productId) {
    let review = 'https://api.technodom.kz/feedback/api/v2/reviews/products/';
    let filters = '?limit=10&page=1&mood=&with_photo=';
    return review + productId + filters;
}

(async   ()  => {
    let flag = true
    let res = []
    let counter = 1
    try {
        let browser = await puppeteer.launch({
            headless: false,
        })
        let page = await browser.newPage()
        await page.setViewport({
            width: 1400,
            height: 900
        })
        // console.log(data.data.payload);
        while (flag) {
            await page.goto(`${link}${counter}`)
            let data = await axios.get(api + counter)

            let selector = 'main.Page_block__main__RmRed'
            let pageItem = await page.waitForSelector(selector)
            let links = await page.evaluate(async (element) => {
                    let linksArray = []
                    try {
                        element.scrollIntoView({behavior: 'smooth', block: "end"})
                        await new Promise(function(resolve) { 
                            setTimeout(resolve, 2000)
                        });
                        const a = document.querySelectorAll('li.category-page-list__item > a.category-page-list__item-link')
                        a.forEach(element => {
                            linksArray.push(element.href)
                        });
                    } catch (error) {
                        console.log(error);
                    }
                    return linksArray
                },
                pageItem)
                console.log(links.length);
            for (itemLink in links) {
                let currentData;
                // let currentData = data.data.payload[itemLink]
                const string = links[itemLink]
                const lastSlashIndex = string.lastIndexOf("-");
                const skuId = string.slice(lastSlashIndex + 1);
                data.data.payload.forEach(element => {
                    if (element["sku"] == skuId) {
                        currentData = element
                    }
                })
                if (!currentData) {
                    currentData = data.data.payload[itemLink]
                }
                let reviewData = (await axios.get(reviewApi(currentData["sku"]))).data["reviews"]
                let specModel = new SpecificationModel({
                    shortDescription: currentData["short_description"]
                })
                let arrReview = []
                reviewData.forEach(element => {
                    let reviewModel = new Review({
                        pros: element["advantages"],
                        cons: element["disadvantages"],
                        comment: element["text"],
                        name: element["full_name"],
                        rating: element["rating"]
                    })
                    arrReview.push(reviewModel)
                });
                await page.goto(links[itemLink])
                await page.waitForSelector('div.product__wrapper')
                const model = await page.evaluate(async () => {
                    let colors = []
                    let memories = []
                    let images = []
                    let tempModel = {}
                    // await li.click()
                    // await page.waitForSelector('.product-info__all-spec-button-wrapper')
                    let carousel = document.querySelectorAll('div.thumbs-wrapper > ul > li.thumb > img')
                    let title = document.querySelector('h1.Typography__Title')
                    // let divImage = carousel.querySelectorAll('img')
                    let divColor = document.querySelectorAll('div.AccentVariant__Color')
                    let pMemory = document.querySelectorAll('button.VariantButton > div.VariantButton__Card >  p.VariantButton__Card-Title')
                    divColor.forEach(div => {
                        colors.push(div.style.background)
                    });
                    carousel.forEach(img => {
                        images.push(img.src)
                    });
                    pMemory.forEach(p => {
                        memories.push(p.innerText)
                    });

                    tempModel = {
                        // linkId: document.url,
                        title: title.innerText,
                        price: document.querySelector('p.Typography__Heading').innerText,
                        color: colors,
                        memory: memories,
                        images: images,
                    }
                    // {
                    //     // linkId: hr.slice(27),
                    //     title: title.innerText,
                    //     price: document.querySelector('p.Typography__Heading').innerText,
                    //     color: colors,
                    //     memory: memories,
                    //     images: images
                    // }
                    return tempModel

                }, {
                    waitUntil: 'div.product__wrapper'
                })
                let currentMongoModel = new ParsedModel({
                    id: currentData["sku"],
                    linkId: links[itemLink],
                    title: model.title,
                    price: model.price,
                    color: model.color,
                    memory: model.memory,
                    images: model.images,
                    specification: specModel,
                    reviews: arrReview
                })
                try {
                    await currentMongoModel.save();
                    res.push(currentMongoModel)
                } catch (error) {
                    if (error.code === 11000) {
                        console.log("Duplicate key error, skipping save to the database");
                    } else {
                        throw error
                    }
                }
            }

            for (let i in res) {
                if (res[i].length === 0) {
                    flag = false
                }
            }
            counter++
        }

        await browser.close()
        res = res.flat()
        // fs.writeFile('dns.json', JSON.stringify({'data':res}), err => {
        //     if(err) throw err

        // })


    } catch (error) {
        console.log('Main catcher\n ');
        console.log(error);
    }
})();


app.listen(PORT, "0.0.0.0", () => {
    console.log(`connected at port ${PORT}`);
});