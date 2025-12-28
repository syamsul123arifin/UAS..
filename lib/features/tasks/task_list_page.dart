import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';
import '../../providers/user_provider.dart';
import 'task_detail_page.dart';

class TaskListPage extends StatelessWidget {
  final String courseId;

  const TaskListPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final taskService = TaskService();
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: StreamBuilder<List<Task>>(
        stream: taskService.getTasks(courseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final tasks = snapshot.data ?? [];
          if (tasks.isEmpty) {
            return const Center(child: Text('No tasks available'));
          }
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return FutureBuilder<TaskSubmission?>(
                future: taskService.getSubmission(courseId, task.id, userId),
                builder: (context, subSnapshot) {
                  String status;
                  if (subSnapshot.connectionState == ConnectionState.waiting) {
                    status = 'Loading...';
                  } else if (subSnapshot.hasData) {
                    final submission = subSnapshot.data!;
                    if (submission.score != null) {
                      status = 'Sudah dinilai (${submission.score})';
                    } else {
                      status = 'Sudah dikumpulkan';
                    }
                  } else {
                    status = 'Belum dikumpulkan';
                  }
                  return ListTile(
                    title: Text(task.title),
                    subtitle: Text('Deadline: ${task.deadline.toLocal().toString().split(' ')[0]}\nStatus: $status'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailPage(
                            courseId: courseId,
                            task: task,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}