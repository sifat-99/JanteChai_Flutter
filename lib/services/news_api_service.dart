import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jante_chai/models/article_model.dart';

class NewsApiService {
  static const String _apiKey = 'pub_16cafba88be643f5a9f1bba8d5ffb0ae'; // Updated API Key for newsdata.io
  static const String _baseUrl = 'https://newsdata.io/api/1'; // Base URL for newsdata.io

  Future<List<Article>> fetchTopHeadlines() async {
    final url = Uri.parse('$_baseUrl/latest?apikey=$_apiKey&country=bd');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> articlesJson = data['results']; // Changed from 'articles' to 'results'
        for(var article in articlesJson) {
          if (kDebugMode) {
            print(article); // For debugging purposes
          }
        }
        return articlesJson.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load articles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching articles: $e');
    }
  }
}
