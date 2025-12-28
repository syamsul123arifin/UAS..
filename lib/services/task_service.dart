import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import '../models/task_model.dart';
import 'storage_service.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

  Future<void> createTask({
    required String courseId,
    required String title,
    required String description,
    required DateTime deadline,
    required double maxScore,
  }) async {
    DocumentReference docRef = _firestore
        .collection('courses')
        .doc(courseId)
        .collection('tasks')
        .doc();

    Task task = Task(
      id: docRef.id,
      courseId: courseId,
      title: title,
      description: description,
      deadline: deadline,
      maxScore: maxScore,
      createdAt: DateTime.now(),
    );

    await docRef.set(task.toMap());
  }

  Stream<List<Task>> getTasks(String courseId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('tasks')
        .orderBy('deadline')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> submitTask({
    required String courseId,
    required String taskId,
    required PlatformFile file,
    required String userId,
  }) async {
    String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    String path = 'tasks/$courseId/$taskId/submissions/$userId/$fileName';
    String downloadUrl = await _storageService.uploadFile(file, path);

    DocumentReference docRef = _firestore
        .collection('courses')
        .doc(courseId)
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .doc(userId);

    TaskSubmission submission = TaskSubmission(
      userId: userId,
      fileUrl: downloadUrl,
      submittedAt: DateTime.now(),
      score: null,
    );

    await docRef.set(submission.toMap());
    await _updateProgress(courseId, userId);
  }

  Future<void> gradeSubmission({
    required String courseId,
    required String taskId,
    required String userId,
    required double score,
  }) async {
    await _firestore
        .collection('courses')
        .doc(courseId)
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .doc(userId)
        .update({'score': score});

    await _updateProgress(courseId, userId);
  }

  Stream<List<TaskSubmission>> getSubmissions(String courseId, String taskId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TaskSubmission.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<TaskSubmission?> getSubmission(
      String courseId, String taskId, String userId) async {
    DocumentSnapshot doc = await _firestore
        .collection('courses')
        .doc(courseId)
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .doc(userId)
        .get();

    if (doc.exists) {
      return TaskSubmission.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<void> _updateProgress(String courseId, String userId) async {
    QuerySnapshot tasksSnapshot = await _firestore
        .collection('courses')
        .doc(courseId)
        .collection('tasks')
        .get();

    int totalTasks = tasksSnapshot.docs.length;
    int completedTasks = 0;

    for (var taskDoc in tasksSnapshot.docs) {
      DocumentSnapshot subDoc = await taskDoc.reference
          .collection('submissions')
          .doc(userId)
          .get();
      if (subDoc.exists) {
        completedTasks++;
      }
    }

    double progressPercent = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

    DocumentReference progressRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc(courseId);

    await progressRef.set({
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'progressPercent': progressPercent,
    });
  }
}