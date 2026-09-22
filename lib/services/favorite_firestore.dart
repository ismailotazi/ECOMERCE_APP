import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/services/favorite_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteFirestore {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> mergeGuestFavorites() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final guestFavorites = await FavoriteStorage.loadFavorites();

    if (guestFavorites.isEmpty) return;

    final favoritesRef = _firestore
        .collection("users")
        .doc(user.uid)
        .collection("favorites");

    for (final productId in guestFavorites) {
      await favoritesRef.doc(productId).set({
        "createdAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await FavoriteStorage.clearFavorites();
  }
}
