import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/material_model.dart' as material_model;
import '../../providers/user_provider.dart';
import '../../services/material_service.dart';

class AddMaterialPage extends StatefulWidget {
  final String courseId;

  const AddMaterialPage({super.key, required this.courseId});

  @override
  State<AddMaterialPage> createState() => _AddMaterialPageState();
}

class _AddMaterialPageState extends State<AddMaterialPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  material_model.MaterialType _selectedType = material_model.MaterialType.pdf;
  PlatformFile? _selectedFile;
  bool _isUploading = false;

  final MaterialService _materialService = MaterialService();

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'mp4', 'txt'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
        // Auto-select type based on extension
        String ext = _selectedFile!.extension?.toLowerCase() ?? '';
        if (ext == 'pdf') {
          _selectedType = material_model.MaterialType.pdf;
        } else if (ext == 'mp4') {
          _selectedType = material_model.MaterialType.video;
        } else if (ext == 'txt') {
          _selectedType = material_model.MaterialType.text;
        }
      });
    }
  }

  Future<void> _uploadMaterial() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file')),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      await _materialService.addMaterial(
        courseId: widget.courseId,
        title: _title.trim(),
        description: _description.trim(),
        type: _selectedType,
        uploadedBy: userProvider.currentUser!.uid,
        file: _selectedFile!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Material uploaded successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload material: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Material'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _title = value,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) => _description = value,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<material_model.MaterialType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Material Type',
                  border: OutlineInputBorder(),
                ),
                items: material_model.MaterialType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
                onSaved: (value) => _selectedType = value ?? material_model.MaterialType.pdf,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(_selectedFile != null
                    ? 'File: ${_selectedFile!.name}'
                    : 'Select File'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadMaterial,
                child: _isUploading
                    ? const CircularProgressIndicator()
                    : const Text('Upload Material'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}