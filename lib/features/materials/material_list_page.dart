import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/material_model.dart' as material_model;
import '../../providers/user_provider.dart';
import '../../services/material_service.dart';
import 'material_detail_page.dart';
import 'add_material_page.dart';

class MaterialListPage extends StatelessWidget {
  final String courseId;

  const MaterialListPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;
    final isLecturer = currentUser?.role == 'lecturer';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Materials'),
        actions: isLecturer
            ? [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMaterialPage(courseId: courseId),
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: StreamBuilder<List<material_model.LearningMaterial>>(
        stream: MaterialService().getMaterials(courseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final materials = snapshot.data ?? [];

          if (materials.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.library_books,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isLecturer
                        ? 'No materials uploaded yet. Tap + to add materials.'
                        : 'No materials available for this course.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: materials.length,
            itemBuilder: (context, index) {
              final material = materials[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    _getMaterialIcon(material.type),
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    material.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(material.description),
                      const SizedBox(height: 4),
                      Text(
                        'Uploaded: ${_formatDate(material.uploadedAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MaterialDetailPage(
                          courseId: courseId,
                          material: material,
                        ),
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

  IconData _getMaterialIcon(material_model.MaterialType type) {
    switch (type) {
      case material_model.MaterialType.pdf:
        return Icons.picture_as_pdf;
      case material_model.MaterialType.video:
        return Icons.video_library;
      case material_model.MaterialType.text:
        return Icons.text_snippet;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}