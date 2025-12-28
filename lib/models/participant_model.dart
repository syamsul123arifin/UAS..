import 'package:cloud_firestore/cloud_firestore.dart';

class Participant {
  final String userId;
  final String courseId;
  final DateTime joinedAt;

  Participant({
    required this.userId,
    required this.courseId,
    required this.joinedAt,
  });

  factory Participant.fromMap(Map<String, dynamic> data, String userId, String courseId) {
    return Participant(
      userId: userId,
      courseId: courseId,
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'joinedAt': joinedAt,
    };
  }
}