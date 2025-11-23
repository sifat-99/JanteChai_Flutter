import 'dart:convert';
import 'package:http/http.dart' as http;

// You might need to add http: ^0.13.0 or a similar version to your pubspec.yaml
// dependencies section if you haven't already.

class ApiService {
  static const String _baseUrl = 'http://localhost:5001/api';
  // static const String _baseUrl = 'https://jante-chaii-backend.vercel.app/api'; // Updated to your Vercel backend URL
  // Generic GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // Handle non-200 responses
        throw Exception('Failed to load data from $endpoint: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Handle network errors
      throw Exception('Failed to connect to $endpoint: $e');
    }
  }

  // Generic POST request
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');
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
        throw Exception('Failed to post data to $endpoint: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to $endpoint: $e');
    }
  }

  // Generic PUT request
  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');
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
        throw Exception('Failed to put data to $endpoint: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to $endpoint: $e');
    }
  }

  // Generic DELETE request
  static Future<void> delete(String endpoint) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');
    try {
      final response = await http.delete(uri);

      if (response.statusCode != 200 && response.statusCode != 204) {
        // Handle non-200 responses
        throw Exception('Failed to delete data from $endpoint: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Handle network errors
      throw Exception('Failed to connect to $endpoint: $e');
    }
  }
}
