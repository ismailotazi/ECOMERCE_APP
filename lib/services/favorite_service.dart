import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  Future<void> toggleFavorite(String productId) async {
    final ref = _firestore
        .collection("users")
        .doc(uid)
        .collection("favorites")
        .doc(productId);

    final doc = await ref.get();

    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({"createdAt": FieldValue.serverTimestamp()});
    }
  }

  Stream<bool> isFavorite(String productId) {
    return _firestore
        .collection("users")
        .doc(uid)
        .collection("favorites")
        .doc(productId)
        .snapshots()
        .map((doc) => doc.exists);
  }
}
