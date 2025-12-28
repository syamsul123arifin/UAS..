import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String lecturerId;
  final String lecturerName;
  final bool isActive;
  final DateTime createdAt;
  final List<String> enrolledStudents;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.lecturerId,
    required this.lecturerName,
    required this.isActive,
    required this.createdAt,
    required this.enrolledStudents,
  });

  factory Course.fromMap(Map<String, dynamic> data, String id) {
    return Course(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      lecturerId: data['lecturerId'] ?? '',
      lecturerName: data['lecturerName'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      enrolledStudents: List<String>.from(data['enrolledStudents'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'lecturerId': lecturerId,
      'lecturerName': lecturerName,
      'isActive': isActive,
      'createdAt': createdAt,
      'enrolledStudents': enrolledStudents,
    };
  }
}

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getCourses() {
  return FirebaseFirestore.instance
      .collection('courses')
      .where('isActive', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .snapshots();
}


  Future<void> createCourse({
    required String title,
    required String description,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User belum login');
    }

    await _firestore.collection('courses').add({
      'title': title,
      'description': description,
      'lecturerId': user.uid,
      'lecturerName': user.email, // bisa diganti ambil dari users
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'enrolledStudents': [],
    });
  }

  Future<List<Course>> getAllCourses() async {
    final snapshot = await _firestore.collection('courses').get();
    return snapshot.docs.map((doc) => Course.fromMap(doc.data(), doc.id)).toList();
  }

  Future<List<Course>> getEnrolledCourses(String userId) async {
    final snapshot = await _firestore
        .collection('courses')
        .where('enrolledStudents', arrayContains: userId)
        .get();
    return snapshot.docs.map((doc) => Course.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> enrollInCourse(String courseId, String userId) async {
    await _firestore.collection('courses').doc(courseId).update({
      'enrolledStudents': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> unenrollFromCourse(String courseId, String userId) async {
    await _firestore.collection('courses').doc(courseId).update({
      'enrolledStudents': FieldValue.arrayRemove([userId]),
    });
  }
}
