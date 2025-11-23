import 'package:flutter/material.dart';
import 'package:jante_chai/models/comment_model.dart';
import 'package:jante_chai/services/auth_service.dart';
import 'package:jante_chai/services/news_api_service.dart';

class MyCommentsScreen extends StatefulWidget {
  const MyCommentsScreen({super.key});

  @override
  State<MyCommentsScreen> createState() => _MyCommentsScreenState();
}

class _MyCommentsScreenState extends State<MyCommentsScreen> {
  late Future<List<Comment>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _commentsFuture = _getComments();
  }

  Future<List<Comment>> _getComments() async {
    final userEmail = authService.currentUser.value?.email;
    if (userEmail == null) {
      return [];
    }

    final articles = await NewsApiService.getNews();
    final comments = <Comment>[];

    for (final article in articles) {
      if (article.comments != null) {
        for (final comment in article.comments!) {
          if (comment.commenterEmail == userEmail) {
            comments.add(Comment(
              id: comment.id,
              commenterName: comment.commenterName,
              commenterEmail: comment.commenterEmail,
              content: comment.content,
              createdAt: comment.createdAt,
              replies: comment.replies,
              articleTitle: article.title,
            ));
          }
        }
      }
    }

    return comments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Comments'),
      ),
      body: FutureBuilder<List<Comment>>(
        future: _commentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No comments found.'));
          }

          final comments = snapshot.data!;

          return ListView.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (comment.articleTitle != null)
                        Text(
                          comment.articleTitle!,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      if (comment.articleTitle != null) const SizedBox(height: 8),
                      Text(
                        comment.content,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'on: ${comment.createdAt}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
