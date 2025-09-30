import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:wemaro/core/data/user_data.dart';

class ApiService {
  final Dio _dio;
  static const String _baseUrl = 'https://randomuser.me/api';
  static const int _resultsLimit = 50;

  ApiService() : _dio = Dio() {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<List<User>> fetchUsers() async {
    try {
      // Check connectivity before making the request
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw DioException(
          requestOptions: RequestOptions(path: _baseUrl),
          error: 'No internet connection',
          type: DioExceptionType.connectionError,
        );
      }

      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'results': _resultsLimit,
          'inc': 'name,id,picture',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        final List<dynamic> results = jsonData['results'] as List;
        return results.map((json) => User.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: _baseUrl),
          response: response,
          error: 'Failed to load users: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow; // Let the caller handle the error
    }
  }

// Add other API methods here as needed
}