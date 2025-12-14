import 'package:flutter/material.dart';
import 'package:jante_chai/models/article_model.dart';
import 'package:jante_chai/services/auth_service.dart';
import 'package:jante_chai/services/news_api_service.dart';
import 'package:jante_chai/services/saved_news_service.dart';

import 'package:jante_chai/utils/image_utils.dart';

class NewsDetailsScreen extends StatefulWidget {
  final Article article;

  const NewsDetailsScreen({Key? key, required this.article}) : super(key: key);

  @override
  State<NewsDetailsScreen> createState() => _NewsDetailsScreenState();
}

class _NewsDetailsScreenState extends State<NewsDetailsScreen> {
  late Article _currentArticle;
  final _commentController = TextEditingController();
  final _replyControllers = <String, TextEditingController>{};
  String? _replyingToCommentId;
  final Set<String> _expandedCommentIds = {};
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _currentArticle = widget.article;
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final isSaved = await savedNewsService.isArticleSaved(widget.article.id);
    if (mounted) {
      setState(() {
        _isSaved = isSaved;
      });
    }
  }

  Future<void> _toggleSave() async {
    if (_isSaved) {
      await savedNewsService.removeArticle(_currentArticle.id);
    } else {
      await savedNewsService.saveArticle(_currentArticle);
    }
    setState(() {
      _isSaved = !_isSaved;
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _replyControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _refreshArticle() async {
    final article = await NewsApiService.getArticleById(widget.article.id);
    setState(() {
      _currentArticle = article;
    });
  }

  void _showLoginAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please log in to perform this action.')),
    );
  }

  Future<void> _addComment() async {
    if (!authService.isLoggedIn.value) {
      _showLoginAlert();
      return;
    }
    if (_commentController.text.isNotEmpty) {
      try {
        await NewsApiService.addComment(
          newsId: _currentArticle.id,
          commenterName: authService.currentUser.value!.name,
          commenterEmail: authService.currentUser.value!.email,
          content: _commentController.text,
        );
        _commentController.clear();
        await _refreshArticle();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to add comment: $e')));
        }
      }
    }
  }

  Future<void> _addReply(String commentId) async {
    if (!authService.isLoggedIn.value) {
      _showLoginAlert();
      return;
    }
    final controller = _replyControllers[commentId];
    if (controller != null && controller.text.isNotEmpty) {
      try {
        await NewsApiService.addReply(
          newsId: _currentArticle.id,
          commentId: commentId,
          replierName: authService.currentUser.value!.name,
          replierEmail: authService.currentUser.value!.email,
          content: controller.text,
        );
        controller.clear();
        setState(() {
          _replyingToCommentId = null;
        });
        await _refreshArticle();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to add reply: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = authService.isLoggedIn.value;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(_currentArticle.title),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: _isSaved ? Theme.of(context).colorScheme.primary : null,
            ),
            onPressed: _toggleSave,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_currentArticle.imageUrl != null &&
                _currentArticle.imageUrl!.isNotEmpty)
              Image.network(
                ImageUtils.getCompatibleImageUrl(_currentArticle.imageUrl!),
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint(
                    'Image failed to load in details: ${_currentArticle.imageUrl}',
                  );
                  debugPrint('Error: $error');
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.broken_image,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
            const SizedBox(height: 16.0),
            Text(
              _currentArticle.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              _currentArticle.description ?? '',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16.0),
            const Divider(),
            const SizedBox(height: 16.0),
            Text(
              'Comments (${_currentArticle.comments?.length})',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _currentArticle.comments?.length,
              itemBuilder: (context, index) {
                final comment = _currentArticle.comments![index];
                _replyControllers.putIfAbsent(
                  comment.id,
                  () => TextEditingController(),
                );
                final areRepliesVisible = _expandedCommentIds.contains(
                  comment.id,
                );
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(comment.commenterName),
                          subtitle: Text(comment.content),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () {
                                  if (!isLoggedIn) {
                                    _showLoginAlert();
                                    return;
                                  }
                                  setState(() {
                                    _replyingToCommentId = comment.id;
                                  });
                                },
                                child: const Text('Reply'),
                              ),
                            ],
                          ),
                        ),
                        if (_replyingToCommentId == comment.id)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              bottom: 8.0,
                            ),
                            child: TextField(
                              controller: _replyControllers[comment.id],
                              decoration: InputDecoration(
                                hintText: 'Add a reply...',
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: () => _addReply(comment.id),
                                ),
                              ),
                            ),
                          ),
                        if (comment.replies.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                if (areRepliesVisible) {
                                  _expandedCommentIds.remove(comment.id);
                                } else {
                                  _expandedCommentIds.add(comment.id);
                                }
                              });
                            },
                            child: Text(
                              areRepliesVisible
                                  ? 'Hide Replies'
                                  : 'Show Replies (${comment.replies.length})',
                            ),
                          ),
                        if (areRepliesVisible && comment.replies.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 32.0),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: comment.replies.length,
                              itemBuilder: (context, replyIndex) {
                                final reply = comment.replies[replyIndex];
                                return ListTile(
                                  title: Text(reply.replierName),
                                  subtitle: Text(reply.content),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _commentController,
              enabled: isLoggedIn,
              decoration: InputDecoration(
                hintText: isLoggedIn
                    ? 'Add a comment...'
                    : 'Please log in to comment',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: isLoggedIn ? _addComment : _showLoginAlert,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
