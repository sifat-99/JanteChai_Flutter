import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jante_chai/models/article_model.dart';

class NewsApiService {
  static const String _apiKey = '8c6fe5fad3ea4a92b694981b8068b17e'; // Your API Key
  static const String _baseUrl = 'https://newsapi.org/v2';

  Future<List<Article>> fetchTopHeadlines() async {
    final url = Uri.parse('$_baseUrl/top-headlines?country=us&apiKey=$_apiKey');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> articlesJson = data['articles'];
        for(var article in articlesJson) {
          if (kDebugMode) {
            print(article);
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


