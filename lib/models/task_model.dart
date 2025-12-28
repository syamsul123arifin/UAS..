import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final DateTime deadline;
  final double maxScore;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.deadline,
    required this.maxScore,
    required this.createdAt,
  });

  factory Task.fromMap(Map<String, dynamic> data, String id) {
    return Task(
      id: id,
      courseId: data['courseId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      deadline: (data['deadline'] as Timestamp).toDate(),
      maxScore: (data['maxScore'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'title': title,
      'description': description,
      'deadline': Timestamp.fromDate(deadline),
      'maxScore': maxScore,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class TaskSubmission {
  final String userId;
  final String fileUrl;
  final DateTime submittedAt;
  final double? score;

  TaskSubmission({
    required this.userId,
    required this.fileUrl,
    required this.submittedAt,
    this.score,
  });

  factory TaskSubmission.fromMap(Map<String, dynamic> data, String userId) {
    return TaskSubmission(
      userId: userId,
      fileUrl: data['fileUrl'] ?? '',
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      score: data['score']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fileUrl': fileUrl,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'score': score,
    };
  }
}