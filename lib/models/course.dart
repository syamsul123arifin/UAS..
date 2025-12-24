class Course {
  final String id;
  final String title;
  final String description;
  final String lecturerId;
  final String lecturerName;
  final List<String> enrolledStudents;
  final bool isActive;
  final DateTime createdAt;
  final String? imageUrl;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.lecturerId,
    required this.lecturerName,
    required this.enrolledStudents,
    required this.isActive,
    required this.createdAt,
    this.imageUrl,
  });

  factory Course.fromMap(Map<String, dynamic> data, String id) {
    return Course(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      lecturerId: data['lecturerId'] ?? '',
      lecturerName: data['lecturerName'] ?? '',
      enrolledStudents: List<String>.from(data['enrolledStudents'] ?? []),
      isActive: data['isActive'] ?? true,
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'lecturerId': lecturerId,
      'lecturerName': lecturerName,
      'enrolledStudents': enrolledStudents,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}