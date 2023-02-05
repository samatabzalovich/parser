import 'dart:convert';

import 'review.dart';
import 'specification.dart';

class ParsedModel {
  final String id;
  final String linkId;
  String title;
  String price;
  final List<String> color;
  final List<String> memory;
  final List<String> images;
  final List<Specification> specification;
  final List<Review> reviews;
  ParsedModel({
    required this.id,
    required this.linkId,
    required this.title,
    required this.price,
    required this.color,
    required this.memory,
    required this.images,
    required this.specification,
    required this.reviews,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'id': id});
    result.addAll({'linkId': linkId});
    result.addAll({'title': title});
    result.addAll({'price': price});
    result.addAll({'color': color});
    result.addAll({'memory': memory});
    result.addAll({'images': images});
    result.addAll({'specification': specification.map((x) => x.toMap()).toList()});
    result.addAll({'reviews': reviews.map((x) => x.toMap()).toList()});
  
    return result;
  }

  factory ParsedModel.fromMap(Map<String, dynamic> map) {
    return ParsedModel(
      id: map['id'] ?? '',
      linkId: map['linkId'] ?? '',
      title: map['title'] ?? '',
      price: map['price'] ?? '',
      color: List<String>.from(map['color']),
      memory: List<String>.from(map['memory']),
      images: List<String>.from(map['images']),
      specification: List<Specification>.from(map['specification']?.map((x) => Specification.fromMap(x))),
      reviews: List<Review>.from(map['reviews']?.map((x) => Review.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory ParsedModel.fromJson(String source) => ParsedModel.fromMap(json.decode(source));
}
