const fs = require('fs');
const puppeteer = require('puppeteer');

let link = "https://www.technodom.kz/catalog/smartfony-i-gadzhety/smartfony-i-telefony/smartfony?page=";

(async () => {
    let flag = true
    let res = []
    let counter = 1
    try {
        let browser = await puppeteer.launch({
            headless: false,
            slowMo: 100,
            devtools: true
        })
        let page = await browser.newPage()
        await page.setViewport({
            width:1400, height: 900
        })
        while (flag) {
            await page.goto(`${link}${counter}`)
            await page.waitForSelector('div.Paginator__List-ArrowIcon-Right')
            let arrayOfModels = await page.evaluate(async () => {
                let tempArray = []
                try {
                    let lis = document.querySelectorAll('li.category-page-list__item')
                    lis.forEach( async (li) => {
                        let a = li.querySelector('a.category-page-list__item-link')
                        let titleTag =a.querySelector('p.ProductCardV__Title')
                        let priceTag = a.querySelector('p.ProductCardV__Price')
                        await page.goto(a.href)
                        let currentModel = await page.evaluate(async () => {
                            let colors = []
                            let memories = []
                            let images = []
                            let tempModel = {}
                            try {
                                let mainDiv = document.querySelector('div.product-info__variants')
                                let carousel = document.querySelectorAll('div.thumbs-wrapper')

                                let divImage = carousel.querySelectorAll('img')
                                let divColor = mainDiv.querySelectorAll('div.AccentVariant__Color')
                                let pMemory = mainDiv.querySelectorAll('p.VariantButton__Card-Title')
                                divColor.forEach(div => {
                                    colors.push(div.style.background)
                                });
                                divImage.forEach(div => {
                                    images.push(divImage.src)
                                });
                                pMemory.forEach(p => {
                                    memories.push(p.innerText)
                                });
                                tempModel = {
                                    linkId: a.href.slice(27),
                                    title: titleTag.innerText,
                                    price: priceTag.innerText,
                                    color: colors,
                                    memory: memories,
                                    images: images
                                }
                            } catch (error) {
                                console.log(error);
                            }
                            return tempModel
                        }, {waitUntil: 'div.product-info__all-spec-button-wrapper'})
                        tempArray.push(currentModel)
                    })
                } catch (error) {
                    console.log(error)
                }
                return tempArray
            }, {waitUntil: 'div.Paginator__List-ArrowIcon-Right'})
            console.log(arrayOfModels);
            res.push(arrayOfModels)
            for (let i in res) {
                if(res[i].length === 0) {
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
})()


function parseFunc(page) {
    // let tempArray = []
    // try {
    //     let lis = document.querySelectorAll('li.category-page-list__item')
    //     lis.forEach(li => {
    //         let a = li.querySelector('a.category-page-list__item-link')
    //         let titleTag =a.querySelector('p.ProductCardV__Title')
    //         let priceTag = a.querySelector('p.ProductCardV__Price')
    //         let model = {
    //             linkId: a.href.slice(27),
    //             title: titleTag.innerText,
    //             price: priceTag.innerText,
    //             color: [{
    //                 r : 120,
    //                 g: 120,
    //                 b: 120
    //             }],
    //             memory: ['ss'],
    //             images: ['ss']
    //         }
    //         tempArray.push(model)
    //     })
    // } catch (error) {
    //     console.log(error)
    // }
    // return tempArray

    let tempArray = []
    try {
        let lis = document.querySelectorAll('li.category-page-list__item')
        lis.forEach(async li => {
            let a = li.querySelector('a.category-page-list__item-link')
            let titleTag = a.querySelector('p.ProductCardV__Title')
            let priceTag = a.querySelector('p.ProductCardV__Price')
            await page.click(a.href)
            await Promise.all([
                page.click('button[type="submit"]'),
                page.waitForNavigation()
            ]);
            let currentModel = await page.evaluate(async () => {
                let colors = []
                let memories = []
                let images = []
                let tempModel = {}
                try {
                    let mainDiv = document.querySelector('div.product-info__variants')
                    let carousel = document.querySelectorAll('div.thumbs-wrapper')

                    let divImage = carousel.querySelectorAll('img')
                    let divColor = mainDiv.querySelectorAll('div.AccentVariant__Color')
                    let pMemory = mainDiv.querySelectorAll('p.VariantButton__Card-Title')
                    divColor.forEach(div => {
                        colors.push(div.style.background)
                    });
                    divImage.forEach(div => {
                        images.push(divImage.src)
                    });
                    pMemory.forEach(p => {
                        memories.push(p.innerText)
                    });
                    tempModel = {
                        linkId: a.href.slice(27),
                        title: titleTag.innerText,
                        price: priceTag.innerText,
                        color: colors,
                        memory: memories,
                        images: images
                    }
                } catch (error) {
                    console.log(error);
                }
                return tempModel
            }, {
                waitUntil: 'div.product-info__all-spec-button-wrapper'
            })
            tempArray.push(currentModel)
        })
    } catch (error) {
        console.log(error)
    }
    return tempArray
}