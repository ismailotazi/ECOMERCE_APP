import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserSettingsService {
  UserSettingsService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<Map<String, dynamic>> getSettings() async {
    final user = _auth.currentUser;

    if (user == null) {
      return {};
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) {
      return {};
    }

    final data = doc.data();

    return {
      'theme': data?['theme'] ?? 'system',
      'language': data?['language'] ?? 'system',
    };
  }

  static Future<void> saveTheme(String theme) async {
    final user = _auth.currentUser;

    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'theme': theme,
    }, SetOptions(merge: true));
  }

  static Future<void> saveLanguage(String language) async {
    final user = _auth.currentUser;

    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'language': language,
    }, SetOptions(merge: true));
  }
}
