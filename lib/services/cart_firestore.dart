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

  static Future<List<Map<String, dynamic>>> loadCart() async {
    if (_user == null) return [];

    final snapshot = await _cartRef.get();

    if (!snapshot.exists) return [];

    final data = snapshot.data();

    if (data == null || data["items"] is! List) {
      return [];
    }

    return (data["items"] as List)
        .map(
          (item) =>
              Map<String, dynamic>.from(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  static Future<List<Map<String, dynamic>>> syncCart() async {
    if (_user == null) {
      return await CartStorage.loadCart();
    }

    final localCart = await CartStorage.loadCart();
    final remoteCart = await loadCart();

    // Local cart exists, Firebase cart doesn't exist yet.
    if (remoteCart.isEmpty && localCart.isNotEmpty) {
      await saveCart(localCart);
      return localCart;
    }

    // Firebase cart exists, local cart is empty.
    if (remoteCart.isNotEmpty && localCart.isEmpty) {
      await CartStorage.saveCart(remoteCart);
      return remoteCart;
    }

    // Both are empty.
    if (remoteCart.isEmpty && localCart.isEmpty) {
      return [];
    }

    // Both have products.
    // Firebase products are added first.
    // Local products override the same product.
    final mergedCart = <String, Map<String, dynamic>>{};

    for (final item in remoteCart) {
      final productId = item["id"]?.toString();

      if (productId != null && productId.isNotEmpty) {
        mergedCart[productId] = Map<String, dynamic>.from(item);
      }
    }

    for (final item in localCart) {
      final productId = item["id"]?.toString();

      if (productId != null && productId.isNotEmpty) {
        mergedCart[productId] = Map<String, dynamic>.from(item);
      }
    }

    final result = mergedCart.values.toList();

    // Save the merged cart on both sides.
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

  static Stream<List<Map<String, dynamic>>> cartStream() {
    if (_user == null) {
      return const Stream.empty();
    }

    return _cartRef.snapshots().map((snapshot) {
      if (!snapshot.exists) return [];

      final data = snapshot.data();

      if (data == null || data["items"] is! List) {
        return [];
      }

      return (data["items"] as List)
          .map(
            (item) => Map<String, dynamic>.from(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    });
  }
}
