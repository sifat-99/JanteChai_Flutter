class Reply {
  final String replierName;
  final String replierEmail;
  final String content;
  final DateTime createdAt;

  Reply({
    required this.replierName,
    required this.replierEmail,
    required this.content,
    required this.createdAt,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      replierName: json['replierName'],
      replierEmail: json['replierEmail'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Comment {
  final String id;
  final String commenterName;
  final String commenterEmail;
  final String content;
  final DateTime createdAt;
  final List<Reply> replies;

  Comment({
    required this.id,
    required this.commenterName,
    required this.commenterEmail,
    required this.content,
    required this.createdAt,
    required this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    var repliesList = json['replies'] as List? ?? [];
    List<Reply> replies = repliesList.map((i) => Reply.fromJson(i)).toList();

    return Comment(
      id: json['_id'],
      commenterName: json['commenterName'],
      commenterEmail: json['commenterEmail'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      replies: replies,
    );
  }
}
