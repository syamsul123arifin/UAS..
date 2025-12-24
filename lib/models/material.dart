enum MaterialType { video, pdf, text }

class LearningMaterial {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final MaterialType type;
  final String contentUrl; // URL for video/PDF, or text content
  final String uploadedBy;
  final DateTime uploadedAt;
  final int order;

  LearningMaterial({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.type,
    required this.contentUrl,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.order,
  });

  factory LearningMaterial.fromMap(Map<String, dynamic> data, String id) {
    return LearningMaterial(
      id: id,
      courseId: data['courseId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: MaterialType.values[data['type'] ?? 0],
      contentUrl: data['contentUrl'] ?? '',
      uploadedBy: data['uploadedBy'] ?? '',
      uploadedAt: DateTime.parse(data['uploadedAt'] ?? DateTime.now().toIso8601String()),
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'title': title,
      'description': description,
      'type': type.index,
      'contentUrl': contentUrl,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt.toIso8601String(),
      'order': order,
    };
  }
}