class CourseProgress {
  final String id;
  final String studentId;
  final String courseId;
  final double completionPercentage;
  final List<String> completedMaterials;
  final List<String> completedAssignments;
  final List<String> completedQuizzes;
  final DateTime lastAccessed;

  CourseProgress({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.completionPercentage,
    required this.completedMaterials,
    required this.completedAssignments,
    required this.completedQuizzes,
    required this.lastAccessed,
  });

  factory CourseProgress.fromMap(Map<String, dynamic> data, String id) {
    return CourseProgress(
      id: id,
      studentId: data['studentId'] ?? '',
      courseId: data['courseId'] ?? '',
      completionPercentage: (data['completionPercentage'] ?? 0).toDouble(),
      completedMaterials: List<String>.from(data['completedMaterials'] ?? []),
      completedAssignments: List<String>.from(data['completedAssignments'] ?? []),
      completedQuizzes: List<String>.from(data['completedQuizzes'] ?? []),
      lastAccessed: DateTime.parse(data['lastAccessed'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'courseId': courseId,
      'completionPercentage': completionPercentage,
      'completedMaterials': completedMaterials,
      'completedAssignments': completedAssignments,
      'completedQuizzes': completedQuizzes,
      'lastAccessed': lastAccessed.toIso8601String(),
    };
  }
}

class Grade {
  final String id;
  final String studentId;
  final String courseId;
  final String itemId; // assignment or quiz id
  final String itemType; // 'assignment' or 'quiz'
  final double score;
  final double maxScore;
  final String? feedback;
  final DateTime gradedAt;

  Grade({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.itemId,
    required this.itemType,
    required this.score,
    required this.maxScore,
    required this.gradedAt,
    this.feedback,
  });

  factory Grade.fromMap(Map<String, dynamic> data, String id) {
    return Grade(
      id: id,
      studentId: data['studentId'] ?? '',
      courseId: data['courseId'] ?? '',
      itemId: data['itemId'] ?? '',
      itemType: data['itemType'] ?? '',
      score: (data['score'] ?? 0).toDouble(),
      maxScore: (data['maxScore'] ?? 100).toDouble(),
      feedback: data['feedback'],
      gradedAt: DateTime.parse(data['gradedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'courseId': courseId,
      'itemId': itemId,
      'itemType': itemType,
      'score': score,
      'maxScore': maxScore,
      'feedback': feedback,
      'gradedAt': gradedAt.toIso8601String(),
    };
  }
}