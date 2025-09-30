import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:wemaro/core/data/user_data.dart';
import 'package:wemaro/services/api_services/api_services.dart';

class UserNotifier extends Notifier<List<User>> {
  static const String _cachedUsersKey = 'cached_users';
  final ApiService _apiService = ApiService();

  @override
  List<User> build() {
    // Initial synchronous state
    return [];
  }

  Future<void> fetchUsers() async {
    // Start with cached data if available
    state = await _loadCachedUsers();

    try {
      final users = await _apiService.fetchUsers();
      state = users;
      await _cacheUsers(users); // Cache the fresh data
    } catch (e) {
      // If network fails, stick with cached data or empty list if no cache
      final cachedUsers = await _loadCachedUsers();
      state = cachedUsers;
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        // Handle no internet specifically
        state = cachedUsers; // Ensure cached users are shown
      } else {
        // For other errors, still use cached users
        state = cachedUsers;
      }
    }
  }

  Future<void> _cacheUsers(List<User> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = users.map((user) => user.toJson()).toList();
      await prefs.setString(_cachedUsersKey, jsonEncode(jsonList));
    } catch (e) {
      // Silently fail if caching doesn't work
      print('Failed to cache users: $e');
    }
  }

  Future<List<User>> _loadCachedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cachedUsersKey);
    if (cached != null) {
      try {
        final jsonList = jsonDecode(cached) as List;
        return jsonList
            .map((json) => User.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        // If parsing fails, clear corrupted cache and return empty list
        print('Failed to load cached users: $e');
        await prefs.remove(_cachedUsersKey);
        return [];
      }
    }
    return [];
  }
}

final userProvider = NotifierProvider<UserNotifier, List<User>>(() => UserNotifier());