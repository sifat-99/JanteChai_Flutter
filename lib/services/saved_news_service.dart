import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jante_chai/models/article_model.dart';

class SavedNewsService {
  static const String _savedArticlesKey = 'saved_articles';
  final ValueNotifier<List<String>> savedArticleIds = ValueNotifier([]);

  // Singleton instance
  static final SavedNewsService _instance = SavedNewsService._internal();
  factory SavedNewsService() => _instance;
  SavedNewsService._internal() {
    _loadSavedIds();
  }

  Future<void> _loadSavedIds() async {
    final articles = await getSavedArticles();
    savedArticleIds.value = articles.map((a) => a.id).toList();
  }

  Future<List<Article>> getSavedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedString = prefs.getString(_savedArticlesKey);
    if (savedString == null || savedString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> jsonList = jsonDecode(savedString);
      return jsonList.map((json) => Article.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error decoding saved articles: $e');
      return [];
    }
  }

  Future<void> saveArticle(Article article) async {
    final prefs = await SharedPreferences.getInstance();
    final savedArticles = await getSavedArticles();

    // Check if already saved to avoid duplicates
    if (savedArticles.any((element) => element.id == article.id)) {
      return;
    }

    savedArticles.add(article);
    await prefs.setString(
      _savedArticlesKey,
      jsonEncode(savedArticles.map((e) => e.toJson()).toList()),
    );

    // Update notifier
    savedArticleIds.value = [...savedArticleIds.value, article.id];
  }

  Future<void> removeArticle(String articleId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedArticles = await getSavedArticles();

    savedArticles.removeWhere((article) => article.id == articleId);
    await prefs.setString(
      _savedArticlesKey,
      jsonEncode(savedArticles.map((e) => e.toJson()).toList()),
    );

    // Update notifier
    savedArticleIds.value = savedArticles.map((a) => a.id).toList();
  }

  Future<bool> isArticleSaved(String articleId) async {
    final savedArticles = await getSavedArticles();
    return savedArticles.any((article) => article.id == articleId);
  }
}

final savedNewsService = SavedNewsService();
