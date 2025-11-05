import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:jante_chai/models/article_model.dart';

class ArticleCard extends StatelessWidget {
  final Article article;

  const ArticleCard({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      child: InkWell(
        onTap: () {
          // Navigate to NewsDetailsScreen, passing the article object as extra
          context.push('/details', extra: article);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.urlToImage != null)
                Image.network(
                  article.urlToImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(), // Handle image loading errors
                ),
              if (article.urlToImage != null) const SizedBox(height: 12.0),
              Text(
                article.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8.0),
              Text(
                article.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.bookmark_border),
                    onPressed: () {
                      // TODO: Implement save article functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Article saved! (feature coming soon)')),
                      );
                    },
                  ),
                  Text(
                    article.source.name,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
