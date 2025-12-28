import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(PlatformFile file, String path) async {
    Reference ref = _storage.ref().child(path);
    UploadTask uploadTask;
    if (file.bytes != null) {
      uploadTask = ref.putData(file.bytes!);
    } else {
      uploadTask = ref.putFile(File(file.path!));
    }
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}