import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../providers/user_provider.dart';
import 'course_detail_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, enrolled, available

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search courses...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Filter: '),
                    DropdownButton<String>(
                      value: _filterStatus,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All')),
                        DropdownMenuItem(value: 'enrolled', child: Text('Enrolled')),
                        DropdownMenuItem(value: 'available', child: Text('Available')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filterStatus = value!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final courses = snapshot.data!.docs
              .map((doc) => Course.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .where((course) {
                // Search filter
                if (_searchQuery.isNotEmpty) {
                  if (!course.title.toLowerCase().contains(_searchQuery) &&
                      !course.description.toLowerCase().contains(_searchQuery)) {
                    return false;
                  }
                }

                // Status filter
                if (_filterStatus == 'enrolled') {
                  return course.enrolledStudents.contains(user.uid);
                } else if (_filterStatus == 'available') {
                  return !course.enrolledStudents.contains(user.uid) && course.isActive;
                }

                return course.isActive;
              })
              .toList();

          if (courses.isEmpty) {
            return const Center(child: Text('No courses found'));
          }

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              final isEnrolled = course.enrolledStudents.contains(user.uid);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: course.imageUrl != null
                      ? Image.network(course.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.school, size: 50),
                  title: Text(course.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                      Text('Lecturer: ${course.lecturerName}'),
                      Text('Enrolled: ${course.enrolledStudents.length} students'),
                    ],
                  ),
                  trailing: user.role == 'lecturer'
                      ? PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              // TODO: Implement edit course
                            } else if (value == 'delete') {
                              await FirebaseFirestore.instance
                                  .collection('courses')
                                  .doc(course.id)
                                  .delete();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        )
                      : isEnrolled
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : ElevatedButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('courses')
                                    .doc(course.id)
                                    .update({
                                  'enrolledStudents': FieldValue.arrayUnion([user.uid])
                                });
                              },
                              child: const Text('Enroll'),
                            ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailScreen(course: course),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: user.role == 'lecturer'
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Implement add course screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add course coming soon')),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}