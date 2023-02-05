import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_technodom/parsed_model_page.dart';
import 'package:flutter_application_technodom/review.dart';
import 'package:flutter_application_technodom/specification.dart';
import 'package:http/http.dart' as http;

import 'parsed_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ParsedModel> _parsedModels = [];
  int pagination = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getParsedModels(page, limit);
  }

  _getParsedModels(int page, int limit) async {
    final response = await http.get(Uri.parse(
        'http://192.168.1.66:3000/parsedModels?page=$page&limit=$limit'));
    _parsedModels = [];
    if (response.statusCode == 200) {
      List parsedModelsArray = (json.decode(response.body)
          as Map<String, dynamic>)["parsedModels"] as List;

      setState(() {
        _parsedModels =
            parsedModelsArray.map((e) => ParsedModel.fromMap(e)).toList();
      });
    } else {
      throw Exception('Failed to load Parsed Models');
    }
  }

  _deleteParsedModel(String id) async {
    try {
      final response = await http
          .delete(Uri.parse('http://192.168.1.66:3000/parsedmodel-delete/$id'));
      if (response.statusCode == 200) {
        setState(() {
          _parsedModels.removeWhere((parsedModel) => parsedModel.id == id);
        });
      } else {
        throw Exception('Failed to delete Parsed Model');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  _updateModel(String id, ParsedModel model, int index) async {
    try {
      final headers = {"Content-type": "application/json"};
      final response = await http.put(
          Uri.parse('http://192.168.1.66:3000/parsedmodel/$id'), body: model.toJson(), headers: headers);
      if (response.statusCode == 200) {
        setState(() {
          _parsedModels[index] = model;
        });
      } else {
        throw Exception('Failed to update Parsed Model');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void _showUpdateParsedModelBottomSheet(
      BuildContext context, ParsedModel model, int index) {
    final _formKey = GlobalKey<FormState>();


    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 500, // Set the height of the bottom sheet
          child: SingleChildScrollView(
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: model.title,
                        onChanged: (value) => setState(() => model.title = value),
                        decoration: InputDecoration(labelText: 'Title'),
                        validator: (value) =>
                            value!.isEmpty ? 'Title cannot be empty' : null,
                      ),
                      TextFormField(
                        initialValue: model.price,
                        onChanged: (value) => setState(() => model.price = value),
                        decoration: InputDecoration(labelText: 'Price'),
                        validator: (value) =>
                            value!.isEmpty ? 'Price cannot be empty' : null,
                      ),
                      SizedBox(height: 16),
                      Text("Specifications:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Column(
                        children: [
                          ...List.generate(
                              (model.specification[0]
                                          .descriptionMap['shortDescription']
                                      as List)
                                  .length, (i) {
                            var arr = model.specification[0]
                                .descriptionMap['shortDescription'];
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
                      ElevatedButton(
                          onPressed: () async {
                            await _updateModel(model.id, model, index);
                          },
                          child: Text('Update'))
                    ],
                  ))),
        );
      },
    );
  }

  int page = 1;
  int limit = 10;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Technodom visualization"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _parsedModels.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ParsedModelPage(
                                  model: _parsedModels[index],
                                  deleteModel: _deleteParsedModel,
                                )));
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 200,
                            child: PageView.builder(
                              itemCount: _parsedModels[index].images.length,
                              itemBuilder: (context, i) {
                                String currentImage =
                                    _parsedModels[index].images[i];
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
                            _parsedModels[index].title,
                            style: TextStyle(fontSize: 30),
                          ),
                          Text(
                            _parsedModels[index].price,
                            style: TextStyle(
                                fontSize: 25,
                                color: Color.fromARGB(255, 216, 78, 68)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Builder(builder: (context) {
                        List<Color> colors =
                            _parsedModels[index].color.map((colorStr) {
                          // remove "rgb(" and ")" from the color string
                          colorStr = colorStr
                              .replaceAll("rgb(", "")
                              .replaceAll(")", "");
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
                                      border: Border.all(
                                          color: Colors.black38, width: 1),
                                      color: colors[k],
                                    )))
                          ],
                        );
                      }),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // const Text('memory:', style: TextStyle(color: Colors.grey, fontSize: 20),),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ...List.generate(
                                  _parsedModels[index].memory.length,
                                  (j) => Container(
                                    margin: EdgeInsets.all(5),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        border: Border.all(
                                            color: Colors.blue, width: 1)),
                                    child: Text(
                                      _parsedModels[index].memory[j],
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await _deleteParsedModel(_parsedModels[index].id);
                          },
                          icon: Icon(Icons.delete),
                          iconSize: 35,
                        ),
                        IconButton(
                          onPressed: () {
                            _showUpdateParsedModelBottomSheet(
                                context, _parsedModels[index], index);
                          },
                          icon: Icon(Icons.update),
                          iconSize: 35,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                );
              },
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    if (page == 1) {
                      return;
                    }
                    setState(() {
                      page--;
                      _getParsedModels(page, limit);
                    });
                  },
                  child: Text('Previous'),
                ),
                Text(page.toString()),
                TextButton(
                  onPressed: () {
                    page++;
                    _getParsedModels(page, limit);
                    setState(() {});
                  },
                  child: Text('Next'),
                ),
              ],
            ),
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
