import 'package:flutter/material.dart';

import 'package:flutter_application_technodom/parsed_model.dart';

class ParsedModelPage extends StatelessWidget {
  final ParsedModel model;
  final Function deleteModel;
  const ParsedModelPage({
    Key? key,
    required this.model,
    required this.deleteModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text(model.id),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200,
                child: PageView.builder(
                  itemCount: model.images.length,
                  itemBuilder: (context, i) {
                    String currentImage = model.images[i];
                    if (currentImage.startsWith('data')) {
                      currentImage =
                          'https://reactnativecode.com/wp-content/uploads/2018/01/Error_Img.png';
                    }
                    return Image.network(
                      currentImage,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              Text(
                model.title,
                style: TextStyle(fontSize: 30),
              ),
              Text(
                model.price,
                style: TextStyle(
                    fontSize: 25, color: Color.fromARGB(255, 216, 78, 68)),
              ),
              Text("ID: ${model.id}",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("Link ID: ${model.linkId}"),
              SizedBox(height: 16),
              Container(
                child: Builder(builder: (context) {
                  List<Color> colors = model.color.map((colorStr) {
                    // remove "rgb(" and ")" from the color string
                    colorStr =
                        colorStr.replaceAll("rgb(", "").replaceAll(")", "");
                    // split the string into separate r, g, b values
                    List<String> colorValues = colorStr.split(",");
                    // parse each value as an integer
                    int r = int.parse(colorValues[0].trim());
                    int g = int.parse(colorValues[1].trim());
                    int b = int.parse(colorValues[2].trim());
                    // return the Color object
                    return Color.fromRGBO(r, g, b, 1);
                  }).toList();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(
                          colors.length,
                          (k) => Container(
                              margin: EdgeInsets.only(right: 5),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black38, width: 1),
                                color: colors[k],
                              )))
                    ],
                  );
                }),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // const Text('memory:', style: TextStyle(color: Colors.grey, fontSize: 20),),
                  Container(
                    child: Row(
                      children: [
                        ...List.generate(
                          model.memory.length,
                          (j) => Container(
                            margin: EdgeInsets.all(5),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                border:
                                    Border.all(color: Colors.blue, width: 1)),
                            child: Text(
                              model.memory[j],
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await deleteModel(model.id);
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.delete),
                    iconSize: 35,
                  )
                ],
              ),

              SizedBox(height: 16),
              Text("Specifications:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Column(
                children: [
                  ...List.generate(
                      (model.specification[0].descriptionMap['shortDescription']
                              as List)
                          .length, (i) {
                    var arr = model
                        .specification[0].descriptionMap['shortDescription'];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          arr[i]['title'],
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          arr[i]['values'][0]['value_ru'],
                          textAlign: TextAlign.right,
                        ),
                      ],
                    );
                  })
                ],
              ),
              SizedBox(height: 8),

              ...List.generate((model.reviews).length, (i) {
                var arr = model.reviews;
                return Container(
                  // alignment: Alignmen,
                  width: MediaQuery.of(context).size.width / 2,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black45)),
                  child: Column(
                    children: [
                      Text(
                        'Pros',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(arr[i].pros, textAlign: TextAlign.left),
                      Text('Cons',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        arr[i].cons,
                        textAlign: TextAlign.left,
                      ),
                      Text('comment',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        arr[i].comment,
                        textAlign: TextAlign.left,
                      ),
                      Text('name',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        arr[i].name,
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                );
              })

              // SizedBox(height: 16),
              // Text("Reviews:", style: TextStyle(fontWeight: FontWeight.bold)),
              // SizedBox(height: 8),
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: model.reviews.map((review) => Padding(
              //     padding: EdgeInsets.only(bottom: 8),
              //     child: Text("- ${review.username}: ${review.text}"),
              //   )).toList(),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
