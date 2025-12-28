import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';
import '../../providers/user_provider.dart';

class TaskDetailPage extends StatefulWidget {
  final String courseId;
  final Task task;

  const TaskDetailPage({super.key, required this.courseId, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TaskService _taskService = TaskService();
  PlatformFile? _selectedFile;
  bool _isUploading = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _submitTask() async {
    if (_selectedFile == null) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      _isUploading = true;
    });
    try {
      await _taskService.submitTask(
        courseId: widget.courseId,
        taskId: widget.task.id,
        file: _selectedFile!,
        userId: userProvider.currentUser!.uid,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task submitted successfully')),
      );
      setState(() {
        _selectedFile = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    if (user == null) return const SizedBox();
    final isLecturer = user.role == 'lecturer'; // assume role field

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${widget.task.description}'),
            Text('Deadline: ${widget.task.deadline.toLocal()}'),
            Text('Max Score: ${widget.task.maxScore}'),
            const SizedBox(height: 20),
            if (isLecturer) ...[
              const Text('Submissions:'),
              Expanded(
                child: StreamBuilder<List<TaskSubmission>>(
                  stream: _taskService.getSubmissions(widget.courseId, widget.task.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    final submissions = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: submissions.length,
                      itemBuilder: (context, index) {
                        final submission = submissions[index];
                        return ListTile(
                          title: Text('User: ${submission.userId}'),
                          subtitle: Text('Score: ${submission.score ?? 'Not graded'}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showGradeDialog(submission.userId, submission.score);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ] else ...[
              FutureBuilder<TaskSubmission?>(
                future: _taskService.getSubmission(widget.courseId, widget.task.id, user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  final submission = snapshot.data;
                  if (submission != null) {
                    return Column(
                      children: [
                        Text('Submitted at: ${submission.submittedAt}'),
                        Text('Score: ${submission.score ?? 'Not graded'}'),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.attach_file),
                          label: Text(_selectedFile != null ? _selectedFile!.name : 'Select File'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _isUploading ? null : _submitTask,
                          child: _isUploading ? const CircularProgressIndicator() : const Text('Submit Task'),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showGradeDialog(String userId, double? currentScore) {
    final scoreController = TextEditingController(text: currentScore?.toString() ?? '');
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Grade Submission'),
          content: TextField(
            controller: scoreController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Score'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                double? score = double.tryParse(scoreController.text);
                if (score != null) {
                  try {
                    await _taskService.gradeSubmission(
                      courseId: widget.courseId,
                      taskId: widget.task.id,
                      userId: userId,
                      score: score,
                    );
                    if (!mounted) return;
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Graded successfully')),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed: $e')),
                    );
                  }
                }
              },
              child: const Text('Grade'),
            ),
          ],
        );
      },
    );
  }
}