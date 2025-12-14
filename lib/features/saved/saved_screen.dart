import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jante_chai/models/article_model.dart';
import 'package:jante_chai/services/saved_news_service.dart';
import 'package:jante_chai/widgets/article_card.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Articles')),
      body: ValueListenableBuilder<List<String>>(
        valueListenable: savedNewsService.savedArticleIds,
        builder: (context, savedIds, child) {
          return FutureBuilder<List<Article>>(
            future: savedNewsService.getSavedArticles(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No saved articles found.'),
                    ],
                  ),
                );
              }

              final articles = snapshot.data!;
              return ListView.builder(
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return InkWell(
                    onTap: () {
                      context.push('/details', extra: article);
                    },
                    child: ArticleCard(article: article),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
