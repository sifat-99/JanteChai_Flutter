import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jante_chai/models/article_model.dart';

class CategoryNewsScreen extends StatelessWidget {
  final String categoryName;
  final List<Article> articles;

  const CategoryNewsScreen({
    super.key,
    required this.categoryName,
    required this.articles,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: articles.isEmpty
          ? const Center(child: Text('No news found for this category.'))
          : ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                  child: ListTile(
                    title: Text(article.title),
                    subtitle: Text(
                      article.description ?? 'No description available.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      context.push('/details', extra: article);
                    },
                  ),
                );
              },
            ),
    );
  }
}
