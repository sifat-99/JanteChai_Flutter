import 'package:flutter/foundation.dart';
import 'package:jante_chai/models/article_model.dart';
import 'package:jante_chai/models/comment_model.dart';
import 'package:jante_chai/services/api_service.dart';

class NewsApiService {
  static Future<List<Article>> getNews() async {
    try {
      final response = await ApiService.get('news');
      debugPrint('Loaded news data: $response');
      final List<dynamic> newsList = response['news'];
      return newsList.map((json) => Article.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<Article> getArticleById(String newsId) async {
    try {
      final response = await ApiService.get('news/$newsId');
      return Article.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Comment>> getCommentsByUser(String userEmail) async {
    try {
      final response = await ApiService.get('comments/user/$userEmail');
      final List<dynamic> commentsList = response['comments'];
      return commentsList.map((json) => Comment.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> publishNews({
    required String title,
    required String description,
    String? pictureUrl,
    String? category,
    required String reporterEmail,
  }) async {
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'reporterEmail': reporterEmail,
    };
    if (pictureUrl != null && pictureUrl.isNotEmpty) {
      data['pictureUrl'] = pictureUrl;
    }
    if (category != null && category.isNotEmpty) {
      data['category'] = category;
    }

    try {
      await ApiService.post('news/publish', data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateNews(String newsId, Map<String, dynamic> data) async {
    try {
      await ApiService.put('news/$newsId', data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteNews(String newsId) async {
    try {
      await ApiService.delete('news/$newsId');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> addComment({
    required String newsId,
    required String commenterName,
    required String commenterEmail,
    required String content,
  }) async {
    final Map<String, dynamic> data = {
      'commenterName': commenterName,
      'commenterEmail': commenterEmail,
      'content': content,
    };

    try {
      await ApiService.post('news/$newsId/comments', data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> addReply({
    required String newsId,
    required String commentId,
    required String replierName,
    required String replierEmail,
    required String content,
  }) async {
    final Map<String, dynamic> data = {
      'replierName': replierName,
      'replierEmail': replierEmail,
      'content': content,
    };

    try {
      await ApiService.post('news/$newsId/comments/$commentId/replies', data);
    } catch (e) {
      rethrow;
    }
  }
}
