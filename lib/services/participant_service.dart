import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/participant_model.dart';

class ParticipantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Join a course - creates participant document
  Future<void> joinCourse(String courseId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to join a course');
    }

    final participantRef = _firestore
        .collection('courses')
        .doc(courseId)
        .collection('participants')
        .doc(user.uid);

    final participant = Participant(
      userId: user.uid,
      courseId: courseId,
      joinedAt: DateTime.now(),
    );

    await participantRef.set(participant.toMap());
  }

  /// Leave a course - deletes participant document
  Future<void> leaveCourse(String courseId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to leave a course');
    }

    final participantRef = _firestore
        .collection('courses')
        .doc(courseId)
        .collection('participants')
        .doc(user.uid);

    await participantRef.delete();
  }

  /// Check if user is participant of a course
  Future<bool> isParticipant(String courseId, String userId) async {
    final participantRef = _firestore
        .collection('courses')
        .doc(courseId)
        .collection('participants')
        .doc(userId);

    final doc = await participantRef.get();
    return doc.exists;
  }

  /// Get all participants of a course
  Future<List<Participant>> getParticipants(String courseId) async {
    final participantsRef = _firestore
        .collection('courses')
        .doc(courseId)
        .collection('participants');

    final snapshot = await participantsRef.get();

    return snapshot.docs.map((doc) {
      return Participant.fromMap(doc.data(), doc.id, courseId);
    }).toList();
  }

  /// Get courses that user has joined
  Future<List<String>> getUserJoinedCourses(String userId) async {
    final coursesRef = _firestore.collection('courses');
    final coursesSnapshot = await coursesRef.get();

    final joinedCourseIds = <String>[];

    for (final courseDoc in coursesSnapshot.docs) {
      final participantRef = courseDoc.reference
          .collection('participants')
          .doc(userId);

      final participantDoc = await participantRef.get();
      if (participantDoc.exists) {
        joinedCourseIds.add(courseDoc.id);
      }
    }

    return joinedCourseIds;
  }

  /// Stream of participants for a course (real-time updates)
  Stream<List<Participant>> getParticipantsStream(String courseId) {
    final participantsRef = _firestore
        .collection('courses')
        .doc(courseId)
        .collection('participants');

    return participantsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Participant.fromMap(doc.data(), doc.id, courseId);
      }).toList();
    });
  }
}