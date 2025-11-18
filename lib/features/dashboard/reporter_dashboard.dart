import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jante_chai/models/article_model.dart';
import 'package:jante_chai/services/auth_service.dart';
import 'package:jante_chai/services/news_api_service.dart';

class ReporterDashboard extends StatefulWidget {
  const ReporterDashboard({super.key});

  @override
  State<ReporterDashboard> createState() => _ReporterDashboardState();
}

class _ReporterDashboardState extends State<ReporterDashboard> {
  List<Article> _news = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    authService.currentUser.addListener(_fetchNews);
    _fetchNews();
  }

  @override
  void dispose() {
    authService.currentUser.removeListener(_fetchNews);
    super.dispose();
  }

  Future<void> _fetchNews() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final reporterEmail = authService.currentUser.value?.email;
      if (reporterEmail == null) {
        if (mounted) {
          setState(() {
            _news = [];
            _isLoading = false;
          });
        }
        return;
      }
      final allNews = await NewsApiService.getNews();
      final reporterNews = allNews
          .where((article) => article.reporterEmail == reporterEmail)
          .toList();

      if (mounted) {
        setState(() {
          _news = reporterNews;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteNews(String newsId) async {
    try {
      await NewsApiService.deleteNews(newsId);
      _fetchNews(); // Refresh the list after deleting
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _showEditDialog(Article article) async {
    final titleController = TextEditingController(text: article.title);
    final categoryController = TextEditingController(text: article.category);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modify News'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                try {
                  await NewsApiService.updateNews(article.id, {
                    'title': titleController.text,
                    'category': categoryController.text,
                  });
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  _fetchNews(); // Refresh the list
                } catch (e) {
                  // Handle error
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporter Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.publish),
              title: const Text('Publish News'),
              onTap: () {
                context.push('/publish_news');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                context.push('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Published News'),
              onTap: () {
                context.push('/published_news');
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _news.isEmpty
              ? const Center(child: Text('No news published yet.'))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Title')),
                      DataColumn(label: Text('Category')), 
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: _news.map((article) {
                      return DataRow(cells: [
                        DataCell(Text(article.title)),
                        DataCell(Text(article.category ?? 'N/A')),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditDialog(article),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteNews(article.id),
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
    );
  }
}
