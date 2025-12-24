class Quiz {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final int timeLimit; // in minutes
  final DateTime dueDate;
  final String lecturerId;
  final DateTime createdAt;

  Quiz({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.questions,
    required this.timeLimit,
    required this.dueDate,
    required this.lecturerId,
    required this.createdAt,
  });

  factory Quiz.fromMap(Map<String, dynamic> data, String id) {
    return Quiz(
      id: id,
      courseId: data['courseId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      questions: (data['questions'] as List<dynamic>?)
          ?.map((q) => QuizQuestion.fromMap(q))
          .toList() ?? [],
      timeLimit: data['timeLimit'] ?? 30,
      dueDate: DateTime.parse(data['dueDate'] ?? DateTime.now().toIso8601String()),
      lecturerId: data['lecturerId'] ?? '',
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toMap()).toList(),
      'timeLimit': timeLimit,
      'dueDate': dueDate.toIso8601String(),
      'lecturerId': lecturerId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> data) {
    return QuizQuestion(
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswerIndex: data['correctAnswerIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
    };
  }
}

class QuizSubmission {
  final String id;
  final String quizId;
  final String studentId;
  final String studentName;
  final List<int> answers; // indices of selected answers
  final DateTime submittedAt;
  final double score;

  QuizSubmission({
    required this.id,
    required this.quizId,
    required this.studentId,
    required this.studentName,
    required this.answers,
    required this.submittedAt,
    required this.score,
  });

  factory QuizSubmission.fromMap(Map<String, dynamic> data, String id) {
    return QuizSubmission(
      id: id,
      quizId: data['quizId'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      answers: List<int>.from(data['answers'] ?? []),
      submittedAt: DateTime.parse(data['submittedAt'] ?? DateTime.now().toIso8601String()),
      score: (data['score'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'studentId': studentId,
      'studentName': studentName,
      'answers': answers,
      'submittedAt': submittedAt.toIso8601String(),
      'score': score,
    };
  }
}