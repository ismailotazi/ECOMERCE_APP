import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecomerce_app/services/favorite_storage.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  Future<void> toggleFavorite(String productId) async {
    final userId = uid;

    // ==========================================================
    // GUEST
    // ==========================================================
    if (userId == null) {
      final isFav = await FavoriteStorage.isFavorite(productId);

      if (isFav) {
        await FavoriteStorage.removeFavorite(productId);
      } else {
        await FavoriteStorage.addFavorite(productId);
      }

      return;
    }

    // ==========================================================
    // LOGGED USER
    // ==========================================================
    final ref = _firestore
        .collection("users")
        .doc(userId)
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
    final userId = uid;

    // ==========================================================
    // GUEST
    // ==========================================================
    if (userId == null) {
      return Stream<bool>.multi((controller) async {
        Future<void> emitFavorite() async {
          final value = await FavoriteStorage.isFavorite(productId);

          if (!controller.isClosed) {
            controller.add(value);
          }
        }

        await emitFavorite();

        FavoriteStorage.favoriteChanges.listen((_) async {
          if (!controller.isClosed) {
            await emitFavorite();
          }
        });
      });
    }

    // ==========================================================
    // LOGGED USER
    // ==========================================================
    return _firestore
        .collection("users")
        .doc(userId)
        .collection("favorites")
        .doc(productId)
        .snapshots()
        .map((doc) => doc.exists);
  }
}
