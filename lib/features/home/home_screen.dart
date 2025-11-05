import 'package:flutter/material.dart';
import 'package:jante_chai/models/article_model.dart';
import 'package:jante_chai/services/news_api_service.dart';
import 'package:jante_chai/widgets/article_card.dart';

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
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    setState(() {
      _articlesFuture = NewsApiService().fetchTopHeadlines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        // This dialog will appear if you press back from HomeScreen
        final bool shouldPop = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Do you want to exit an app?'),
            actions: <Widget>[
              TextButton(
                onPressed: () { Navigator.of(context).pop(false); },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () { Navigator.of(context).pop(true); },
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ?? false;
        if (shouldPop) {
          // If you want to exit the app, you might need to use SystemNavigator.pop()
          // or ensure your main GoRouter stack allows popping.
          // For now, let's just observe if this dialog appears.
          // GoRouter.of(context).pop(); // This would pop the shell and exit the app
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Headlines', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),),
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
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final article = snapshot.data![index];
                    return ArticleCard(article: article);
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
