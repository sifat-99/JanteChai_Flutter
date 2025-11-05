import 'package:flutter/material.dart';
import 'package:jante_chai/models/article_model.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailsScreen extends StatefulWidget {
  final Article article;

  const NewsDetailsScreen({Key? key, required this.article}) : super(key: key);

  @override
  State<NewsDetailsScreen> createState() => _NewsDetailsScreenState();
}

class _NewsDetailsScreenState extends State<NewsDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final List<String> _comments = [];

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch \$url');
    }
  }

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        _comments.add(_commentController.text);
        _commentController.clear();
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.article.urlToImage != null)
              Image.network(
                widget.article.urlToImage!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(),
              ),
            const SizedBox(height: 16.0),
            Text(
              widget.article.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            Text(
              'By ${widget.article.author ?? 'Unknown'} - ${widget.article.publishedAt.substring(0, 10)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16.0),
            Text(
              widget.article.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _launchUrl(widget.article.url),
              child: const Text('Read Full Article'),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Comments',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Add a comment...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ),
              onSubmitted: (_) => _addComment(),
            ),
            const SizedBox(height: 16.0),
            _comments.isEmpty
                ? const Text('No comments yet. Be the first to comment!')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(_comments[index]),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
