import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jante_chai/models/article_model.dart';

class ArticleCard extends StatelessWidget {
  final Article article;

  const ArticleCard({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2.0,
      clipBehavior: Clip.antiAlias, // Ensures the image corners are rounded
      child: InkWell(
        onTap: () {
          // Navigate to NewsDetailsScreen, passing the article object
          context.push('/details', extra: article);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              Image.network(
                article.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(), // Don't show anything if image fails
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10.0),
                  if (article.description != null && article.description!.isNotEmpty)
                    Text(
                      article.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8.0),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      article.sourceName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}