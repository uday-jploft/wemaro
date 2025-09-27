import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String id;
  final String name;
  final String avatar;

  User({required this.id, required this.name, required this.avatar});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], name: json['name'], avatar: json['avatar']);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'avatar': avatar};
}

class UserNotifier extends Notifier<List<User>> {
  @override
  List<User> build() => [];

  Future<void> fetchUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      final users = snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
      state = users;
      _cacheUsers(users);
    } catch (e) {
      state = await _loadCachedUsers();
    }
  }

  Future<void> _cacheUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = users.map((user) => user.toJson()).toList();
    prefs.setString('cached_users', jsonEncode(jsonList));
  }

  Future<List<User>> _loadCachedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cached_users');
    if (cached != null) {
      final jsonList = jsonDecode(cached) as List;
      return jsonList.map((json) => User.fromJson(json)).toList();
    }
    return [];
  }
}

final userProvider = NotifierProvider<UserNotifier, List<User>>(() => UserNotifier());