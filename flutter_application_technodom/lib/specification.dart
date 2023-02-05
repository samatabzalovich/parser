import 'dart:convert';

class Specification {
  final Map<String, dynamic> descriptionMap;

  Specification({required this.descriptionMap});


  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'descriptionMap': descriptionMap});
  
    return result;
  }

  factory Specification.fromMap(Map<String, dynamic> map) {
    return Specification(
      descriptionMap: map,
    );
  }

  String toJson() => json.encode(toMap());

  factory Specification.fromJson(String source) => Specification.fromMap(json.decode(source));
}
