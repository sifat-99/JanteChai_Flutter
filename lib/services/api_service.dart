import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // static const String _baseUrl = 'http://localhost:5001/api';
  static String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:5001/api';
  // Generic GET request
  static Future<dynamic> get(String endpoint) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // Handle non-200 responses
        throw Exception(
          'Failed to load data from $endpoint: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      // Handle network errors
      throw Exception('Failed to connect to $endpoint: $e');
    }
  }

  // Generic POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');
    print(uri);
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          return json.decode(response.body);
        } else {
          return {}; // Return an empty map for success with no body
        }
      } else {
        throw Exception(
          'Failed to post data to $endpoint: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to $endpoint: $e');
    }
  }

  // Generic PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');
    print(uri);
    try {
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          return json.decode(response.body);
        } else {
          return {}; // Return an empty map for success with no body
        }
      } else {
        throw Exception(
          'Failed to put data to $endpoint: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to $endpoint: $e');
    }
  }

  // Generic DELETE request
  static Future<void> delete(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');
    print(uri);
    try {
      final response = await http.delete(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: body != null ? json.encode(body) : null,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        // Handle non-200 responses
        throw Exception(
          'Failed to delete data from $endpoint: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      // Handle network errors
      throw Exception('Failed to connect to $endpoint: $e');
    }
  }
}
