import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ================= DELETE USER ACCOUNT =================

  static Future<void> deleteUserAccount() async {
    final user = _auth.currentUser;

    if (user == null) return;

    await _deletePersonalData(user.uid);

    await user.delete();
  }

  // ================= DELETE ADMIN ACCOUNT =================

  static Future<void> deleteAdminAccount() async {
    final user = _auth.currentUser;

    if (user == null) return;

    await _deletePersonalData(user.uid);

    await user.delete();
  }

  // ================= DELETE PERSONAL DATA =================

  static Future<void> _deletePersonalData(String uid) async {
    final userRef = _firestore.collection('users').doc(uid);

    // Cart
    final cartSnapshot = await userRef.collection('cart').get();

    for (final doc in cartSnapshot.docs) {
      await doc.reference.delete();
    }

    // Favorites
    final favoritesSnapshot = await userRef.collection('favorites').get();

    for (final doc in favoritesSnapshot.docs) {
      await doc.reference.delete();
    }

    // User orders subcollection
    final ordersSnapshot = await userRef.collection('orders').get();

    for (final doc in ordersSnapshot.docs) {
      await doc.reference.delete();
    }

    // Notifications
    final notificationsSnapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .get();

    for (final doc in notificationsSnapshot.docs) {
      await doc.reference.delete();
    }

    // users/{uid}
    await userRef.delete();
  }
}
