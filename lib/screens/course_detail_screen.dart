import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../models/material.dart' as material_model;
import '../models/assignment.dart';
import '../models/quiz.dart';
import '../models/forum.dart';
import '../providers/user_provider.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Materials'),
            Tab(text: 'Assignments'),
            Tab(text: 'Quizzes'),
            Tab(text: 'Forum'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Course info header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.course.imageUrl != null)
                  Image.network(widget.course.imageUrl!, height: 150, width: double.infinity, fit: BoxFit.cover),
                const SizedBox(height: 8),
                Text(widget.course.title, style: Theme.of(context).textTheme.headlineSmall),
                Text('Lecturer: ${widget.course.lecturerName}'),
                const SizedBox(height: 4),
                Text(widget.course.description),
                Text('Enrolled: ${widget.course.enrolledStudents.length} students'),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMaterialsTab(),
                _buildAssignmentsTab(),
                _buildQuizzesTab(),
                _buildForumTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('materials')
          .where('courseId', isEqualTo: widget.course.id)
          .orderBy('order')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final materials = snapshot.data!.docs
            .map((doc) => material_model.LearningMaterial.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        if (materials.isEmpty) {
          return const Center(child: Text('No materials available'));
        }

        return ListView.builder(
          itemCount: materials.length,
          itemBuilder: (context, index) {
            final material = materials[index];
            return ListTile(
              leading: Icon(
                material.type == material_model.MaterialType.video ? Icons.play_circle :
                material.type == material_model.MaterialType.pdf ? Icons.picture_as_pdf :
                Icons.text_fields,
                size: 40,
              ),
              title: Text(material.title),
              subtitle: Text(material.description),
              onTap: () {
                // TODO: Open material viewer
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening ${material.title}')),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAssignmentsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('assignments')
          .where('courseId', isEqualTo: widget.course.id)
          .orderBy('dueDate')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final assignments = snapshot.data!.docs
            .map((doc) => Assignment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        if (assignments.isEmpty) {
          return const Center(child: Text('No assignments available'));
        }

        return ListView.builder(
          itemCount: assignments.length,
          itemBuilder: (context, index) {
            final assignment = assignments[index];
            final userProvider = context.watch<UserProvider>();
            final user = userProvider.currentUser;
            final isSubmitted = assignment.submittedStudents.contains(user?.uid ?? '');

            return ListTile(
              title: Text(assignment.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(assignment.description),
                  Text('Due: ${assignment.dueDate.toString().split(' ')[0]}'),
                  Text(isSubmitted ? 'Submitted' : 'Not submitted', style: TextStyle(color: isSubmitted ? Colors.green : Colors.red)),
                ],
              ),
              trailing: isSubmitted ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.assignment),
              onTap: () {
                // TODO: Open assignment detail
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening ${assignment.title}')),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildQuizzesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('quizzes')
          .where('courseId', isEqualTo: widget.course.id)
          .orderBy('dueDate')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final quizzes = snapshot.data!.docs
            .map((doc) => Quiz.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        if (quizzes.isEmpty) {
          return const Center(child: Text('No quizzes available'));
        }

        return ListView.builder(
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            return ListTile(
              title: Text(quiz.title),
              subtitle: Text('Due: ${quiz.dueDate.toString().split(' ')[0]}'),
              trailing: const Icon(Icons.quiz),
              onTap: () {
                // TODO: Open quiz
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening ${quiz.title}')),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildForumTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('forum')
          .where('courseId', isEqualTo: widget.course.id)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!.docs
            .map((doc) => ForumPost.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        if (posts.isEmpty) {
          return const Center(child: Text('No forum posts yet'));
        }

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return ListTile(
              title: Text(post.title),
              subtitle: Text('By ${post.authorName} • ${post.replies.length} replies'),
              onTap: () {
                // TODO: Open forum post detail
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening ${post.title}')),
                );
              },
            );
          },
        );
      },
    );
  }
}