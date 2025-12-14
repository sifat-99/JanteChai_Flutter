import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jante_chai/models/article_model.dart';
import 'package:jante_chai/services/news_api_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<List<Article>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = NewsApiService.getNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: FutureBuilder<List<Article>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No news found.'));
          }

          final articles = snapshot.data!;
          // Extract unique categories, filtering out null or empty ones
          final categories = articles
              .map((article) => article.category)
              .where((category) => category != null && category.isNotEmpty)
              .toSet()
              .toList();

          if (categories.isEmpty) {
            return const Center(child: Text('No categories found.'));
          }

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index]!;
              return ListTile(
                title: Text(category),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Filter articles for this category
                  final categoryArticles = articles
                      .where((article) => article.category == category)
                      .toList();

                  context.push(
                    '/category-news',
                    extra: {
                      'categoryName': category,
                      'articles': categoryArticles,
                    },
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
