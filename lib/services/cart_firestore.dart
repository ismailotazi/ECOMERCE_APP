import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecomerce_app/services/cart_storage.dart';

class CartFirestore {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static User? get _user => FirebaseAuth.instance.currentUser;

  static DocumentReference<Map<String, dynamic>> get _cartRef {
    final user = _user;

    if (user == null) {
      throw Exception("User is not logged in");
    }

    return _firestore
        .collection("users")
        .doc(user.uid)
        .collection("cart")
        .doc("items");
  }

  static Future<void> saveCart(List<Map<String, dynamic>> cartItems) async {
    if (_user == null) return;

    await _cartRef.set({
      "items": cartItems,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  static Future<List<Map<String, dynamic>>> loadCart(String storeId) async {
    if (_user == null) return [];

    if (storeId.isEmpty) return [];

    final snapshot = await _cartRef.get();

    if (!snapshot.exists) return [];

    final data = snapshot.data();

    if (data == null || data["items"] is! List) {
      return [];
    }

    final items = (data["items"] as List)
        .map(
          (item) =>
              Map<String, dynamic>.from(Map<String, dynamic>.from(item as Map)),
        )
        .toList();

    if (items.isEmpty) return [];

    final validItems = <Map<String, dynamic>>[];

    for (final item in items) {
      final itemStoreId = item["storeId"]?.toString();

      // Old cart item without storeId → ignore it.
      if (itemStoreId == null || itemStoreId.isEmpty) {
        continue;
      }

      // Cart item belongs to another store → ignore it.
      if (itemStoreId != storeId) {
        continue;
      }

      final productId = item["id"]?.toString();

      if (productId == null || productId.isEmpty) {
        continue;
      }

      final productDoc = await _firestore
          .collection("products")
          .doc(productId)
          .get();

      if (!productDoc.exists) {
        continue;
      }

      final productData = productDoc.data();

      if (productData == null) {
        continue;
      }

      if (productData["storeId"]?.toString() != storeId) {
        continue;
      }

      validItems.add(item);
    }

    return validItems;
  }

  static Future<List<Map<String, dynamic>>> syncCart(String storeId) async {
    if (storeId.isEmpty) {
      return [];
    }

    // =========================
    // LOGGED USER
    // =========================
    final localCart = await CartStorage.loadCart();

    // IMPORTANT:
    // Never allow products from another store
    // to enter the current store cart.
    final filteredLocalCart = localCart
        .where((item) {
          return item["storeId"]?.toString() == storeId;
        })
        .map((item) {
          return Map<String, dynamic>.from(item);
        })
        .toList();

    // Load remote cart ONLY for current store
    final remoteCart = await loadCart(storeId);

    final mergedCart = <String, Map<String, dynamic>>{};

    // Remote cart
    for (final item in remoteCart) {
      final productId = item["id"]?.toString();

      if (productId == null || productId.isEmpty) {
        continue;
      }

      if (item["storeId"]?.toString() != storeId) {
        continue;
      }

      mergedCart[productId] = Map<String, dynamic>.from(item);
    }

    // Local cart
    for (final item in filteredLocalCart) {
      final productId = item["id"]?.toString();

      if (productId == null || productId.isEmpty) {
        continue;
      }

      if (item["storeId"]?.toString() != storeId) {
        continue;
      }

      mergedCart[productId] = Map<String, dynamic>.from(item);
    }

    final result = mergedCart.values.toList();

    // Save ONLY current store products
    await CartStorage.saveCart(result);
    await saveCart(result);

    return result;
  }

  static Future<void> clearCart() async {
    if (_user != null) {
      await _cartRef.delete();
    }

    await CartStorage.clearCart();
  }

  static Stream<List<Map<String, dynamic>>> cartStream(String storeId) {
    if (_user == null || storeId.isEmpty) {
      return const Stream.empty();
    }

    return _cartRef.snapshots().asyncMap((snapshot) async {
      if (!snapshot.exists) return [];

      final data = snapshot.data();

      if (data == null || data["items"] is! List) {
        return [];
      }

      final items = (data["items"] as List)
          .map(
            (item) => Map<String, dynamic>.from(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();

      if (items.isEmpty) return [];

      final validItems = <Map<String, dynamic>>[];

      for (final item in items) {
        final productId = item["id"]?.toString();

        if (productId == null || productId.isEmpty) {
          continue;
        }

        final productDoc = await _firestore
            .collection("products")
            .doc(productId)
            .get();

        if (!productDoc.exists) {
          continue;
        }

        final productData = productDoc.data();

        if (productData == null) {
          continue;
        }

        if (productData["storeId"]?.toString() != storeId) {
          continue;
        }

        validItems.add(item);
      }

      return validItems;
    });
  }
}
