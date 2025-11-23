import 'package:flutter/material.dart';
import 'package:jante_chai/utils/image_utils.dart';
import 'package:jante_chai/models/article_model.dart';
import 'package:intl/intl.dart';

class ArticleCard extends StatelessWidget {
  final Article article;

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';

    final dateTime = DateTime.parse(dateString);
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  const ArticleCard({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350, // Set a fixed height for the card
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        elevation: 4.0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              Expanded(
                flex: 2,
                child: Image.network(
                  ImageUtils.getCompatibleImageUrl(article.imageUrl!),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Image failed to load: ${article.imageUrl}');
                    debugPrint('Error: $error');
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
              ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      article.description ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'By ${article.reporterEmail ?? 'Unknown'}',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(fontStyle: FontStyle.italic),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          formatDate(article.pubDate),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
