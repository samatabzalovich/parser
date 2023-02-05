import 'dart:convert';

class Review {
  final String pros;
  final String cons;
  final String comment;
  final String name;
  final int rating;
  Review({
    required this.pros,
    required this.cons,
    required this.comment,
    required this.name,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'pros': pros});
    result.addAll({'cons': cons});
    result.addAll({'comment': comment});
    result.addAll({'name': name});
    result.addAll({'rating': rating});
  
    return result;
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      pros: map['pros'] ?? '',
      cons: map['cons'] ?? '',
      comment: map['comment'] ?? '',
      name: map['name'] ?? '',
      rating: map['rating']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Review.fromJson(String source) => Review.fromMap(json.decode(source));
}
