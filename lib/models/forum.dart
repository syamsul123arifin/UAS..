class ForumPost {
  final String id;
  final String courseId;
  final String authorId;
  final String authorName;
  final String title;
  final String content;
  final DateTime createdAt;
  final List<String> likes;
  final List<ForumReply> replies;

  ForumPost({
    required this.id,
    required this.courseId,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.likes,
    required this.replies,
  });

  factory ForumPost.fromMap(Map<String, dynamic> data, String id) {
    return ForumPost(
      id: id,
      courseId: data['courseId'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      likes: List<String>.from(data['likes'] ?? []),
      replies: (data['replies'] as List<dynamic>?)
          ?.map((r) => ForumReply.fromMap(r))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'authorId': authorId,
      'authorName': authorName,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'replies': replies.map((r) => r.toMap()).toList(),
    };
  }
}

class ForumReply {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final List<String> likes;

  ForumReply({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    required this.likes,
  });

  factory ForumReply.fromMap(Map<String, dynamic> data) {
    return ForumReply(
      id: data['id'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      content: data['content'] ?? '',
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      likes: List<String>.from(data['likes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
    };
  }
}