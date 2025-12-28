import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../providers/user_provider.dart';
import '../../services/participant_service.dart';
import '../materials/material_list_page.dart';
import '../materials/add_material_page.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ParticipantService _participantService = ParticipantService();
  bool _isParticipant = false;
  bool _isLoadingParticipant = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkParticipation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkParticipation() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;

    if (currentUser != null) {
      try {
        final isParticipant = await _participantService.isParticipant(
          widget.course.id,
          currentUser.uid,
        );
        if (mounted) {
          setState(() {
            _isParticipant = isParticipant;
            _isLoadingParticipant = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingParticipant = false;
          });
        }
      }
    } else {
      setState(() {
        _isLoadingParticipant = false;
      });
    }
  }

  Future<void> _toggleParticipation() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to join courses')),
      );
      return;
    }

    setState(() {
      _isLoadingParticipant = true;
    });

    try {
      if (_isParticipant) {
        await _participantService.leaveCourse(widget.course.id);
        setState(() {
          _isParticipant = false;
          _isLoadingParticipant = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Left course successfully')),
          );
        }
      } else {
        await _participantService.joinCourse(widget.course.id);
        setState(() {
          _isParticipant = true;
          _isLoadingParticipant = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Joined course successfully')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingParticipant = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;
    final isLecturer = currentUser?.role == 'lecturer';
    final isStudent = currentUser?.role == 'student';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title),
        actions: [
          if (isStudent && !_isLoadingParticipant)
            ElevatedButton.icon(
              onPressed: _toggleParticipation,
              icon: Icon(_isParticipant ? Icons.exit_to_app : Icons.add),
              label: Text(_isParticipant ? 'Leave Course' : 'Join Course'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isParticipant ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          if (_isLoadingParticipant)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Materials', icon: Icon(Icons.library_books)),
            Tab(text: 'Assignments', icon: Icon(Icons.assignment)),
            Tab(text: 'Quizzes', icon: Icon(Icons.quiz)),
            Tab(text: 'Forum', icon: Icon(Icons.forum)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Materials Tab
          MaterialListPage(courseId: widget.course.id),

          // Assignments Tab
          _buildAssignmentsTab(),

          // Quizzes Tab
          _buildQuizzesTab(),

          // Forum Tab
          _buildForumTab(),
        ],
      ),
      floatingActionButton: isLecturer && _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddMaterialPage(courseId: widget.course.id),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildAssignmentsTab() {
    return const Center(
      child: Text('Assignments feature coming soon'),
    );
  }

  Widget _buildQuizzesTab() {
    return const Center(
      child: Text('Quizzes feature coming soon'),
    );
  }

  Widget _buildForumTab() {
    return const Center(
      child: Text('Forum feature coming soon'),
    );
  }
}
