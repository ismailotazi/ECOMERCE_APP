import 'order_item_model.dart';

class OrderModel {
  final String id;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromMap(
    String id,
    Map<String, dynamic> map,
    List<OrderItemModel> items,
  ) {
    return OrderModel(
      id: id,
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null
          ? map['createdAt'].toDate()
          : DateTime.now(),
      items: items,
    );
  }

  Map<String, dynamic> toMap() {
    return {'totalPrice': totalPrice, 'status': status, 'createdAt': createdAt};
  }
}
