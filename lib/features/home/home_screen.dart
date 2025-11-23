import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jante_chai/models/article_model.dart';
import 'package:jante_chai/services/news_api_service.dart';
import 'package:go_router/go_router.dart';
import 'package:jante_chai/widgets/article_card.dart'; // Import go_router

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Article>> _articlesFuture;

  @override
  void initState() {
    super.initState();
    _articlesFuture = NewsApiService.getNews();
  }

  Future<void> _fetchArticles() async {
    setState(() {
      _articlesFuture = NewsApiService.getNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jante Chai News'),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchArticles,
        child: FutureBuilder<List<Article>>(
          future: _articlesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No articles found.'));
            } else {
              final articles = snapshot.data!;
              return ListView.builder(
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return InkWell( // Wrap with InkWell for tap detection
                    onTap: () {
                      context.go('/details', extra: article);
                    },
                    child: ArticleCard(article: article),
                  ).animate().fade(duration: 500.ms);
                },
              );
            }
          },
        ),
      ),
    );
  }
}
