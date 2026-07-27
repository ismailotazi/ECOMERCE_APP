import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_item_model.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrder({
    required String userId,
    required String userName,
    required String email,
    required List<OrderItemModel> items,
    required double totalPrice,
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
      'orderNumber': orderNumber,
      'totalPrice': totalPrice,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'itemsCount': items.length,
    };

    // User Order
    await orderRef.set(orderData);

    // Admin Order
    await adminOrderRef.set(orderData);

    // Admin Notification
    await _firestore.collection('notifications').add({
      'title': 'New Order',
      'body': '$userName placed order $orderNumber',
      'type': 'order',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'orderId': orderRef.id,
      'userId': userId,
    });

    // Save Items
    for (final item in items) {
      final itemData = item.toMap();

      await orderRef.collection('items').add(itemData);

      await adminOrderRef.collection('items').add(itemData);
    }
  }

  Future<List<OrderModel>> getOrders(String userId) async {
    final ordersSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();

    List<OrderModel> orders = [];

    for (final orderDoc in ordersSnapshot.docs) {
      final itemsSnapshot = await orderDoc.reference.collection('items').get();

      final items = itemsSnapshot.docs
          .map((e) => OrderItemModel.fromMap(e.data()))
          .toList();

      orders.add(OrderModel.fromMap(orderDoc.id, orderDoc.data(), items));
    }

    return orders;
  }
}
