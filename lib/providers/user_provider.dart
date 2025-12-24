import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> loadUserData(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      // Error loading user data: $e
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUserData(UserModel user) async {
    _currentUser = user;
    notifyListeners();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update(user.toMap());
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}