import 'package:jante_chai/models/comment_model.dart';

class Article {
  final String id;
  final String? link;
  final String title;
  final String? description;
  final String? content;
  final List<String>? keywords;
  final String? reporterEmail;
  final String? language;
  final List<String>? country;
  final String? category;
  final String? pubDate;
  final String? imageUrl;
  final String? videoUrl;
  final String? sourceId;
  final String? sourceName;
  final String? sourceUrl;
  final String? sourceIcon;
  final List<Comment>? comments;

  Article({
    required this.id,
    this.link,
    required this.title,
    this.description,
    this.content,
    this.keywords,
    this.reporterEmail,
    this.language,
    this.country,
    this.category,
    this.pubDate,
    this.imageUrl,
    this.videoUrl,
    this.sourceId,
    this.sourceName,
    this.sourceUrl,
    this.sourceIcon,
    this.comments,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    var commentsList = json['comments'] as List? ?? [];
    List<Comment> comments = commentsList.map((i) => Comment.fromJson(i)).toList();

    return Article(
      id: json['_id'] ?? '',
      link: json['link'],
      title: json['title'] ?? 'No Title',
      description: json['description'],
      content: json['content'],
      keywords: json['keywords'] != null ? List<String>.from(json['keywords']) : null,
      reporterEmail: json['reporterEmail'],
      language: json['language'],
      country: json['country'] != null ? List<String>.from(json['country']) : [],
      category: json['category'],
      pubDate: json['publishedAt'] ?? json['pubDate'],
      imageUrl: json['pictureUrl'] ?? json['image_url'],
      videoUrl: json['video_url'],
      sourceId: json['source_id'],
      sourceName: json['source_name'],
      sourceUrl: json['source_url'],
      sourceIcon: json['source_icon'],
      comments: comments,
    );
  }
}
