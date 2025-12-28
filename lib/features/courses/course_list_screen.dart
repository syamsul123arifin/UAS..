import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/course_model.dart';
import 'course_detail_screen.dart';


class CourseListPage extends StatelessWidget {
  const CourseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CourseService courseService = CourseService();

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Mata Kuliah')),
      body: StreamBuilder<QuerySnapshot>(
        stream: courseService.getCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada mata kuliah'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data = snapshot.data!.docs[index];
              final course = Course.fromMap(data.data() as Map<String, dynamic>, data.id);

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['title']),
                  subtitle: Text(data['description']),
                  trailing: const Icon(Icons.arrow_forward_ios),
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
    );
  }
}