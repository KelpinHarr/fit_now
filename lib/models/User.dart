import 'dart:convert';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_now/models/WatchedVideo.dart';

class User {
  final String name;
  final List<WatchedVideo> url;
  final int height;
  final int weight;
  final Timestamp date_of_birth;

  User({
    required this.name,
    required this.url,
    required this.height,
    required this.weight,
    required this.date_of_birth,
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
