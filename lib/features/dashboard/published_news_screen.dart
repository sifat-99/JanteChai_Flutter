import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jante_chai/models/article_model.dart';
import 'package:jante_chai/services/auth_service.dart';
import 'package:jante_chai/services/news_api_service.dart';

class PublishedNewsScreen extends StatefulWidget {
  const PublishedNewsScreen({super.key});

  @override
  State<PublishedNewsScreen> createState() => _PublishedNewsScreenState();
}

class _PublishedNewsScreenState extends State<PublishedNewsScreen> {
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

  Future<void> _deleteNews(String newsId, String? reporterEmail) async {
    if (reporterEmail == null) return;
    try {
      await NewsApiService.deleteNews(newsId, reporterEmail);
      _fetchNews(); // Refresh the list after deleting
    } catch (e) {
      // Handle error
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to delete news.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
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
      appBar: AppBar(title: const Text('Published News')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _news.isEmpty
          ? const Center(child: Text('No news published yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _news.length,
              itemBuilder: (context, index) {
                final article = _news[index];
                return Dismissible(
                  key: Key(article.id),
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      // Edit Action
                      await _showEditDialog(article);
                      return false; // Don't dismiss after edit
                    } else {
                      // Delete Action
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm Delete"),
                            content: const Text(
                              "Are you sure you want to delete this news?",
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      // Remove from list immediately to avoid errors
                      setState(() {
                        _news.removeAt(index);
                      });
                      _deleteNews(article.id, article.reporterEmail);
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      title: Text(
                        article.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(article.category ?? 'N/A'),
                      trailing: const Icon(
                        Icons.drag_handle,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        context.push('/details', extra: article);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
