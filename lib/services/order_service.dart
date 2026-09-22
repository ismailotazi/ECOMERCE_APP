import 'dart:math';

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
    String? paymentProofUrl,
    String? paymentBankId,
    String? paymentBankName,
  }) async {
    final orderRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc();

    final adminOrderRef = _firestore.collection('orders').doc(orderRef.id);

    final random = Random();
    final orderNumber = "ORD-${100000 + random.nextInt(900000)}";

    final orderData = {
      'userId': userId,
      'userName': userName,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'country': country,
      'paymentMethod': paymentMethod,
      'paymentProofUrl': paymentProofUrl,
      'paymentBankId': paymentBankId,
      'paymentBankName': paymentBankName,
      'orderNumber': orderNumber,
      'totalPrice': totalPrice,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'itemsCount': items.length,
    };

    // Everything related to stock + order creation
    // happens inside one Firestore transaction.
    await _firestore.runTransaction((transaction) async {
      // --------------------------------------------------
      // 1. Read and validate stock for every product
      // --------------------------------------------------

      final Map<DocumentReference, int> stockUpdates = {};

      for (final item in items) {
        final productId = item.productId.toString();
        final quantity = item.quantity;

        if (productId.isEmpty) {
          throw Exception('Invalid product ID');
        }

        if (quantity <= 0) {
          throw Exception('Invalid product quantity');
        }

        final productRef = _firestore.collection('products').doc(productId);

        final productSnapshot = await transaction.get(productRef);

        if (!productSnapshot.exists) {
          throw Exception('Product no longer exists');
        }

        final data = productSnapshot.data();

        if (data == null) {
          throw Exception('Product data not found');
        }

        final stock = (data['stock'] as num?)?.toInt() ?? 0;

        if (stock < quantity) {
          throw StockException(item.name, stock);
        }

        stockUpdates[productRef] = stock - quantity;
      }

      // --------------------------------------------------
      // 2. Decrease stock
      // --------------------------------------------------

      for (final entry in stockUpdates.entries) {
        transaction.update(entry.key, {'stock': entry.value});
      }

      // --------------------------------------------------
      // 3. Create user order
      // --------------------------------------------------

      transaction.set(orderRef, orderData);

      // --------------------------------------------------
      // 4. Create admin order
      // --------------------------------------------------

      transaction.set(adminOrderRef, orderData);

      // --------------------------------------------------
      // 5. Save order items
      // --------------------------------------------------

      for (final item in items) {
        final itemData = item.toMap();

        final userItemRef = orderRef.collection('items').doc();

        final adminItemRef = adminOrderRef.collection('items').doc();

        transaction.set(userItemRef, itemData);
        transaction.set(adminItemRef, itemData);
      }
    });

    // --------------------------------------------------
    // 6. Admin notification
    // --------------------------------------------------

    await _firestore.collection('notifications').add({
      'title': 'New Order',
      'body': '$userName placed order $orderNumber',
      'type': 'order',
      'recipient': 'admin',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'orderId': orderRef.id,
      'userId': userId,
      'userName': userName,
      'orderNumber': orderNumber,
    });
    // --------------------------------------------------
    // 7. User notification
    // --------------------------------------------------

    await _firestore.collection('notifications').add({
      'title': 'orderPlacedNotification',
      'body': 'orderPlacedNotificationBody',
      'type': 'order_placed',
      'recipient': 'user',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'orderId': orderRef.id,
      'userId': userId,
      'orderNumber': orderNumber,
    });
  }
}
