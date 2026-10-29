import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_item_model.dart';

class StockException implements Exception {
  final String productName;
  final int availableStock;

  StockException(this.productName, this.availableStock);
}

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrder({
    required String userId,
    required String userName,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String country,
    required List<OrderItemModel> items,
    required double totalPrice,
    required String paymentMethod,
    required String storeId,
    String? paymentProofUrl,
    String? paymentBankId,
    String? paymentBankName,
  }) async {
    final orderId = _firestore.collection('orders').doc().id;

    try {
      /*
       * 1. Read all products first
       * 2. Check stock
       * 3. Create root order
       * 4. Create root order items
       * 5. Create user order copy
       * 6. Create user order items
       * 7. Decrease stock
       *
       * Everything is committed atomically.
       */

      final productSnapshots =
          <String, DocumentSnapshot<Map<String, dynamic>>>{};

      for (final item in items) {
        final productId = item.productId.trim();

        if (productId.isEmpty) {
          throw Exception('Invalid product.');
        }

        if (productSnapshots.containsKey(productId)) {
          continue;
        }

        final productSnapshot = await _firestore
            .collection('products')
            .doc(productId)
            .get();

        if (!productSnapshot.exists) {
          throw Exception('Product not found.');
        }

        final productData = productSnapshot.data();

        if (productData == null) {
          throw Exception('Product not found.');
        }

        if (productData['storeId']?.toString() != storeId) {
          throw Exception('Product does not belong to this store.');
        }

        productSnapshots[productId] = productSnapshot;
      }

      // =========================
      // CHECK STOCK
      // =========================

      for (final item in items) {
        final productSnapshot = productSnapshots[item.productId];

        if (productSnapshot == null) {
          throw Exception('Product not found.');
        }

        final productData = productSnapshot.data()!;

        final stock = (productData['stock'] as num?)?.toInt() ?? 0;

        if (item.quantity > stock) {
          throw StockException(item.name, stock);
        }
      }

      // =========================
      // ORDER DATA
      // =========================

      final orderData = <String, dynamic>{
        'orderId': orderId,
        'userId': userId,
        'userName': userName,
        'email': email,
        'phone': phone,
        'address': address,
        'city': city,
        'country': country,
        'storeId': storeId,
        'totalPrice': totalPrice,
        'paymentMethod': paymentMethod,
        'status': 'pending',
        'itemsCount': items.length,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (paymentProofUrl != null && paymentProofUrl.trim().isNotEmpty) {
        orderData['paymentProofUrl'] = paymentProofUrl.trim();
      }

      if (paymentBankId != null && paymentBankId.trim().isNotEmpty) {
        orderData['paymentBankId'] = paymentBankId.trim();
      }

      if (paymentBankName != null && paymentBankName.trim().isNotEmpty) {
        orderData['paymentBankName'] = paymentBankName.trim();
      }

      final batch = _firestore.batch();

      // =========================
      // ROOT ORDER
      // =========================

      final rootOrderRef = _firestore.collection('orders').doc(orderId);

      batch.set(rootOrderRef, orderData);

      // =========================
      // USER ORDER
      // =========================

      final userOrderRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId);

      batch.set(userOrderRef, orderData);

      // =========================
      // ORDER ITEMS
      // =========================

      for (var i = 0; i < items.length; i++) {
        final item = items[i];

        final itemData = item.toMap();

        itemData['orderId'] = orderId;

        // Root item
        final rootItemRef = rootOrderRef.collection('items').doc();

        batch.set(rootItemRef, itemData);

        // User item
        final userItemRef = userOrderRef.collection('items').doc();

        batch.set(userItemRef, itemData);
      }

      // =========================
      // DECREASE STOCK
      // =========================

      final quantitiesByProduct = <String, int>{};

      for (final item in items) {
        quantitiesByProduct[item.productId] =
            (quantitiesByProduct[item.productId] ?? 0) + item.quantity;
      }

      for (final entry in quantitiesByProduct.entries) {
        final productSnapshot = productSnapshots[entry.key];

        if (productSnapshot == null) {
          throw Exception('Product not found.');
        }

        final productData = productSnapshot.data()!;

        final currentStock = (productData['stock'] as num?)?.toInt() ?? 0;

        final newStock = currentStock - entry.value;

        if (newStock < 0) {
          throw StockException(
            productData['name']?.toString() ?? 'Product',
            currentStock,
          );
        }

        batch.update(_firestore.collection('products').doc(entry.key), {
          'stock': newStock,
        });
      }

      // =========================
      // ADMIN NOTIFICATION
      // =========================

      final notificationRef = _firestore.collection('notifications').doc();

      batch.set(notificationRef, {
        'title': 'newOrder',
        'body': 'newOrderBody',
        'type': 'order',
        'recipient': 'admin',
        'userId': userId,
        'userName': userName,
        'storeId': storeId,
        'orderId': orderId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // =========================
      // COMMIT EVERYTHING
      // =========================

      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception(e.message?.isNotEmpty == true ? e.message : e.code);
    } on StockException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
