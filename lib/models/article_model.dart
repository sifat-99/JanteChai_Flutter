class Article {
  final String articleId;
  final String link;
  final String title;
  final String? description;
  final String? content;
  final List<String>? keywords;
  final List<String>? creator;
  final String language;
  final List<String> country;
  final List<String> category;
  final String pubDate;
  final String? imageUrl;
  final String? videoUrl;
  final String sourceId;
  final String sourceName;
  final String sourceUrl;
  final String? sourceIcon;

  Article({
    required this.articleId,
    required this.link,
    required this.title,
    this.description,
    this.content,
    this.keywords,
    this.creator,
    required this.language,
    required this.country,
    required this.category,
    required this.pubDate,
    this.imageUrl,
    this.videoUrl,
    required this.sourceId,
    required this.sourceName,
    required this.sourceUrl,
    this.sourceIcon,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      articleId: json['article_id'] as String? ?? '',
      link: json['link'] as String? ?? '',
      title: json['title'] as String? ?? 'No Title',
      description: json['description'] as String?,
      content: json['content'] as String?,
      keywords: (json['keywords'] as List<dynamic>?)?.map((e) => e as String).toList(),
      creator: (json['creator'] as List<dynamic>?)?.map((e) => e as String).toList(),
      language: json['language'] as String? ?? '',
      country: (json['country'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      category: (json['category'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      pubDate: json['pubDate'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      videoUrl: json['video_url'] as String?,
      sourceId: json['source_id'] as String? ?? '',
      sourceName: json['source_name'] as String? ?? 'Unknown Source',
      sourceUrl: json['source_url'] as String? ?? '',
      sourceIcon: json['source_icon'] as String?,
    );
  }
}
