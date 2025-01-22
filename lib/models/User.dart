import 'dart:convert';

import 'package:fit_now/models/WatchedVideo.dart';

class User {
  final String name;
  final List<WatchedVideo> url;

  User({
    required this.name,
    required this.url
  });

  // factory User.fromJson(Map<String, dynamic> json) => User(
  //   name: json['name'],

  // );
  // List<User> parseUser(String? json){
  //   if (json == null) return [];
  //   final List parsed = jsonDecode(json);
  //   return parsed.map((json) => User.fromJson(json)).toList();
  // }
}