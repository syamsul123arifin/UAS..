class Assignment {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final DateTime dueDate;
  final String lecturerId;
  final DateTime createdAt;
  final List<String> submittedStudents;
  final String? fileUrl; // Optional file attachment

  Assignment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.lecturerId,
    required this.createdAt,
    required this.submittedStudents,
    this.fileUrl,
  });

  factory Assignment.fromMap(Map<String, dynamic> data, String id) {
    return Assignment(
      id: id,
      courseId: data['courseId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: DateTime.parse(data['dueDate'] ?? DateTime.now().toIso8601String()),
      lecturerId: data['lecturerId'] ?? '',
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      submittedStudents: List<String>.from(data['submittedStudents'] ?? []),
      fileUrl: data['fileUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'lecturerId': lecturerId,
      'createdAt': createdAt.toIso8601String(),
      'submittedStudents': submittedStudents,
      'fileUrl': fileUrl,
    };
  }
}

class AssignmentSubmission {
  final String id;
  final String assignmentId;
  final String studentId;
  final String studentName;
  final String? submissionText;
  final String? fileUrl;
  final DateTime submittedAt;
  final double? grade;
  final String? feedback;

  AssignmentSubmission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    this.submissionText,
    this.fileUrl,
    required this.submittedAt,
    this.grade,
    this.feedback,
  });

  factory AssignmentSubmission.fromMap(Map<String, dynamic> data, String id) {
    return AssignmentSubmission(
      id: id,
      assignmentId: data['assignmentId'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      submissionText: data['submissionText'],
      fileUrl: data['fileUrl'],
      submittedAt: DateTime.parse(data['submittedAt'] ?? DateTime.now().toIso8601String()),
      grade: data['grade']?.toDouble(),
      feedback: data['feedback'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'assignmentId': assignmentId,
      'studentId': studentId,
      'studentName': studentName,
      'submissionText': submissionText,
      'fileUrl': fileUrl,
      'submittedAt': submittedAt.toIso8601String(),
      'grade': grade,
      'feedback': feedback,
    };
  }
}