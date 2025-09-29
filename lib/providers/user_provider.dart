import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// User model to hold user details
class User {
  final int id;
  final String name;
  final String avatar;

  User({required this.id, required this.name, required this.avatar});

  factory User.fromJson(Map<String, dynamic> json) {
    // Using a placeholder avatar URL since the fake API doesn't provide avatars
    return User(
      id: json['id'],
      name: json['name'],
      avatar: 'https://via.placeholder.com/50?text=${json['name'].split(' ')[0][0]}', // Mock avatar
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar': avatar,
  };
}

/// User Notifier
class UserNotifier extends Notifier<List<User>> {
  static const String _cachedUsersKey = 'cached_users';
  static const String _apiUrl = 'https://jsonplaceholder.typicode.com/users';

  @override
  List<User> build() {
    // Initial synchronous state
    return [];
  }

  Future<void> fetchUsers() async {
    // Start with cached data if available
    state = await _loadCachedUsers();

    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final users = jsonData.map((json) => User.fromJson(json)).toList();
        state = users;
        _cacheUsers(users); // Cache the fresh data
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      // If network fails, stick with cached data or empty list if no cache
      if (state.isEmpty) {
        state = await _loadCachedUsers();
      }
      // No error state here; let the UI handle empty list
    }
  }

  Future<void> _cacheUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = users.map((user) => user.toJson()).toList();
    await prefs.setString(_cachedUsersKey, jsonEncode(jsonList));
  }

  Future<List<User>> _loadCachedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cachedUsersKey);
    if (cached != null) {
      final jsonList = jsonDecode(cached) as List;
      return jsonList.map((json) => User.fromJson(json)).toList();
    }
    return [];
  }
}

/// Provider
final userProvider = NotifierProvider<UserNotifier, List<User>>(() => UserNotifier());