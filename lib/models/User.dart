import 'dart:convert';

class User {
  final String name;

  User({
    required this.name
  });

  factory User.fromJson(Map<String, dynamic> json) => User(name: json['name']);
  List<User> parseUser(String? json){
    if (json == null) return [];
    final List parsed = jsonDecode(json);
    return parsed.map((json) => User.fromJson(json)).toList();
  }
}