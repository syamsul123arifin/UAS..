import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import '../models/material_model.dart';

class MaterialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Add material with file upload
  Future<void> addMaterial({
    required String courseId,
    required String title,
    required String description,
    required MaterialType type,
    required String uploadedBy,
    required PlatformFile file,
  }) async {
    try {
      // Upload file to Firebase Storage
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      Reference storageRef = _storage.ref().child('materials/$courseId/$fileName');

      UploadTask uploadTask;
      if (file.bytes != null) {
        uploadTask = storageRef.putData(file.bytes!);
      } else {
        uploadTask = storageRef.putFile(File(file.path!));
      }

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Create material document
      DocumentReference docRef = _firestore
          .collection('courses')
          .doc(courseId)
          .collection('materials')
          .doc();

      LearningMaterial material = LearningMaterial(
        id: docRef.id,
        courseId: courseId,
        title: title,
        description: description,
        type: type,
        contentUrl: downloadUrl,
        uploadedBy: uploadedBy,
        uploadedAt: DateTime.now(),
        order: 0, // You can implement ordering logic later
      );

      await docRef.set(material.toMap());
    } catch (e) {
      throw Exception('Failed to add material: $e');
    }
  }

  // Get materials stream for a course
  Stream<List<LearningMaterial>> getMaterials(String courseId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('materials')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return LearningMaterial.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get single material
  Future<LearningMaterial?> getMaterial(String courseId, String materialId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('materials')
          .doc(materialId)
          .get();

      if (doc.exists) {
        return LearningMaterial.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get material: $e');
    }
  }

  // Delete material (optional, for completeness)
  Future<void> deleteMaterial(String courseId, String materialId, String contentUrl) async {
    try {
      // Delete from Firestore
      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('materials')
          .doc(materialId)
          .delete();

      // Delete from Storage
      Reference storageRef = _storage.refFromURL(contentUrl);
      await storageRef.delete();
    } catch (e) {
      throw Exception('Failed to delete material: $e');
    }
  }
}